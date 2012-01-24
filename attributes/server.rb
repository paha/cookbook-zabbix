# 
# Cookbook: zabbix
# Attributes: server
#
# Copyright 2011, LimeLight Networks
#

default.zabbix.server.install = true                                           
default.zabbix.server.version = "1.8.9"                                         
default.zabbix.server.dbhost = "localhost"                                      
default.zabbix.server.dbname = "zabbix"                                         
default.zabbix.server.dbuser = "zabbix"                                     
default.zabbix.server.dbpassword = "za66ix"                                      
default.zabbix.server.dbport = 3306
default.zabbix.server.config_flags = [ 
  "--with-libcurl",
  "--with-net-snmp", 
  "--with-mysql",
  "--with-jabber",
  "--with-openipmi",
  "--with-ldap"
]
default.zabbix.server.debug_level = 2

default.zabbix.server.start_pollers = 4
default.zabbix.server.start_ipmi_pollers = 0
default.zabbix.server.start_pollers_unreachable = 1
default.zabbix.server.start_trappers = 1
default.zabbix.server.start_pingers = 2
default.zabbix.server.start_discoverers = 1
default.zabbix.server.start_http_pollers = 2
default.zabbix.server.cache_size = "24M"
default.zabbix.server.timeout = 5

default.zabbix.server.alert_scripts_path = "/etc/zabbix/alert.d"
default.zabbix.server.external_scripts_path = "/etc/zabbix/externalscripts"

include_attribute "zabbix"
default.zabbix.web.frontend_path = File.join(zabbix.install_path, "frontend")
default.zabbix.web.fqdn = "zabbix.delve.me"
