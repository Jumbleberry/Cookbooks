default['build_essential']['compiletime'] = true
default['build-essential']['compile_time'] = true
default['route53']['nokogiri_version'] = '1.6.3.1'
default['route53']['fog_version'] = '1.24'
default['route53']['instanceIp'] = node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first