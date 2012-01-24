#
# Cookbook: zabbix
# Recipe: default
#

# FIXME:
#

# Maintain zabiix user
user "zabbix" do
  uid 121
  comment "zabbix user"
  home node.zabbix.install_path
  shell "/bin/bash"
end

# Create directory fro zabbix installation
directory node.zabbix.install_path

# Include recipes based on zabbix role, default is agent
# creating a role overriding the 'type' attribute, will make a server type searchable.
node.zabbix.role.each do |role|
  include_recipe "zabbix::#{role}"
end

