default["gearman"]["version"]           = "1.0.*"
default["gearman"]["ip"]                = node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
default['services']['gearman']['host']  = node[:services][:gearman][:host] || "gearman.service.consul"
default['services']['gearman']['port']  = node[:services][:gearman][:port] || "4730"