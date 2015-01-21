# Ensure we are on AWS
if ( node.attribute?('ec2') && node[:ec2].attribute?('instance_id') && /(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]) &&
        node.attribute?('aws') && node['aws'].attribute?('route53') )

  node.override['aws']['route53']['instance_destroy'] = true;

  include_recipe "discovery::add"
end