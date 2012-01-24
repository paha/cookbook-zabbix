#
# Cookbook : zabbix
# Recipe: server
#

# DB (MySQL/Oracle/PostgreSQL/DB2) installation and configuration is not covered by the cookbook.
# We most likely will have external to the server DB
# The code assumes that MySQL is used.

# zabbix user is managed by zabbix::default

# NOTES:

# Package dependencies for compiling zabbix from source: 
%w{
  build-essential
  fping
  bc
  snmp
  libmysqlclient-dev
  libcurl4-openssl-dev
  libsnmp-dev
  libiksemel-dev
  libopenipmi-dev
}.each {|p| package p} 

zbx_dir = "zabbix-#{node.zabbix.server.version}"
config_flags = node.zabbix.server.config_flags
config_flags << "--prefix=#{node.zabbix.install_path}"
# not sure yet what to do for a proxy role.
config_flags << "--enable-server"

template "/etc/init.d/zabbix_server" do
  source "zabbix_server_init.erb"
  mode 0755
end

service "zabbix_server" do
  supports :restart => true
  action [ :start, :enable ]
end

# Obtain zabbix server sources:
remote_file File.join(Chef::Config[:file_cache_path], zbx_dir + ".tar.gz") do
  source  "http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/#{node.zabbix.server.version}/#{zbx_dir}.tar.gz"
  action :create_if_missing
  mode 0644
end

# The conditional statment reseting "install" attr is evaluated before the provider does, thus only_if inside the provider acts too late. 
if node.zabbix.server.install
  # Compile and install zabbix from source:
  bash "install_zbx" do
    # only_if {node.zabbix.server.install}
    user "root"
    cwd Chef::Config[:file_cache_path]
    code <<-INSTALL
      tar -zxf #{zbx_dir}.tar.gz
      cd #{zbx_dir} && ./configure #{config_flags.join(" ")}
      cd #{zbx_dir} && make install
    INSTALL
    notifies :restart, "service[zabbix_server]"
  end
end

# Set install attr to 'false'
if node.zabbix.server.install
  Chef::Log.info("Installed zabbix server from source, settign 'install' attr to false")
  node.set.zabbix.server.install = false 
end

template "/etc/zabbix/zabbix_server.conf" do
  source "zabbix_server.conf.erb"
  mode 0644
  notifies :restart, "service[zabbix_server]"
end
