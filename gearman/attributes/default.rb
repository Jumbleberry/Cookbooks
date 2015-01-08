default["gearman"]["version"]           = "1.0.2*"
default["gearman"]["ip"]                = node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
default['gearman']['mysql']['host']     = ""
default['gearman']['mysql']['user']     = ""
default['gearman']['mysql']['password'] = ""
default['gearman']['mysql']['db']       = ""
default['gearman']['mysql']['table']    = ""
default['gearman']['mysql']['port']     = "3306"
