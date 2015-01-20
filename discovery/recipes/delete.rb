include_recipe "route53"

node.override['aws']['route53']['instance_destroy'] = true;

include_recipe "discovery::add"