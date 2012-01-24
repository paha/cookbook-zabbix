#
# Cookbook: zabbix
# recipe: frontend
#

# node.apache.listen_ports << "443" unless node.apache.listen_ports.include?("443")


%w{
  php5-mysql
  php5-gd
}.each {|p| package p}

# This have to be one level down from existing install dir oor somethign else for permitions and creation to work in this form. 
directory node.zabbix.web.frontend_path do
  owner node.apache.user
  group node.apache.user
  mode  0755
  notifies :run, "bash[copy_php_frontend]"
end

# for frontends on a separate mnode, we would need to get a source... not adding it now.
# Also, code upgrades would need removal of the frontend_path, we could add a attr for that.
zbx_php_path = File.join(Chef::Config[:file_cache_path],"zabbix-#{node.zabbix.server.version}","frontends","php")
# Chef::Log.debug("Path for zabbix php frontend source - #{zbx_php_path}")
# Chef::Log.debug("Frontend path - #{node.zabbix.web.frontend_path}")
bash "copy_php_frontend" do
  action :nothing
  user "root"
  code <<-FRONTEND
    cp -fr #{zbx_php_path}/* #{node.zabbix.web.frontend_path}
    chown -R #{node.apache.user}.#{node.apache.user} #{node.zabbix.web.frontend_path}
  FRONTEND
  notifies :restart, "service[apache2]", :delayed
end

file_base = "/etc/apache2/ssl/#{node.zabbix.web.fqdn}"
bash "create_self_signed_ssl_cert" do
  cwd "/etc/apache2/ssl/"
  code <<-CRT
  umask 077
  openssl genrsa 2048 > #{file_base}.key
  openssl req -subj "/C=US/ST=WA/L=Seattle/O=llnw/OU=vps/CN=#{node.zabbix.web.fqdn}/emailAddress=vps.ops@llnw.com" -new -x509 -nodes -sha1 -days 3650 -key #{file_base}.key > #{file_base}.crt
  CRT
  not_if { File.exists?("#{file_base}.crt") and File.size("#{file_base}.crt") > 0 }
  notifies :restart, "service[apache2]", :delayed
end

include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_ssl"

# disable default site
apache_site "000-default" do
  enable   false
  notifies :restart, "service[apache2]", :delayed
end

# setup zabbix-frontend site
web_app "zabbix-frontend" do
  template      "zabbix-frontend.conf.erb"
  server_name   node.zabbix.web.fqdn
  server_aliases  ["zabbix", node.fqdn]
  doc_root      node.zabbix.web.frontend_path
  notifies      :restart, "service[apache2]", :delayed
end
