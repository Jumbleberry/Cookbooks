include_recipe "route53"

node.override['aws']['route53']['instance_destroy'] = true;

node['aws']['route53']['entries'].each do | entry |
  route53_record "delete a record" do
    name entry.name
    type entry.type
    zone_id entry.zone_id
    aws_access_key_id     node['aws']['aws_access_key_id']
    aws_secret_access_key node['aws']['aws_secret_access_key']
    action :delete
  end
end

include_recipe "discovery::add"