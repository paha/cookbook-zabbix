maintainer       "LimeLight"
maintainer_email "vps.ops@list.llnw.net"
description      "Installs/Configures "
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

recipe  "default", "Takes care of common elements of all zabbix types, and included each of the type attribute."
recipe  "server", "Installs and configures zabbix server."
recipe  "agent", "Installs and configures zabbix agent."
recipe  "frontend", "Installs and configures zabbix php frontend."

# Tested for ubuntu only, at this point.
supports  "ubuntu"

# Dependancies:
%w{
  notifier
  apache2
}.each do |d|
  depends d
end
