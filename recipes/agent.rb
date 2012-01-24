#  
# Cookbook: zabbix
# Recipe: agent
#

# directories:
%w{
  /etc
  /var/log
  /var/run
}.each do |dir|
  directory File.join(dir,"zabbix") do
    mode 0755
    owner "zabbix"
  end
end

template "/etc/init.d/zabbix_agentd" do
  mode 0755
  source "zabbix_agentd.erb"
end

service "zabbix_agentd" do
  supports :status => true, :restart => true
  action [ :start, :enable ]
end

execute "extract_zbx_bin" do
  action :nothing
  cwd Chef::Config[:file_cache_path]
  command "tar zxf zabbix-#{node.zabbix.agent.version}.amd64.tar -C #{node.zabbix.install_path}"
  notifies :restart, "service[zabbix_agentd]"
end

remote_file File.join(Chef::Config[:file_cache_path], "zabbix-#{node.zabbix.agent.version}.amd64.tar") do
  source "http://www.zabbix.com/downloads/#{node.zabbix.agent.version}/zabbix_agents_#{node.zabbix.agent.version}.linux2_6.amd64.tar.gz"
  mode 0644
  action :create_if_missing
  notifies :run, "execute[extract_zbx_bin]"
end

template "/etc/zabbix/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  mode 0644
  notifies :restart, "service[zabbix_agentd]"
end

remote_directory "/etc/zabbix/conf.d" do
  source "conf.d"
  files_backup 0
  files_mode 0644
  mode 0755
  purge true
  # sends service restart every chef run, not sure why, just yet.
  # that is why: 
  # http://tickets.opscode.com/browse/CHEF-2354
  notifies :restart, "service[zabbix_agentd]"
end

remote_directory "/etc/zabbix/scripts" do
  source "scripts"
  files_mode 0755
  mode 0755
  purge true
end
