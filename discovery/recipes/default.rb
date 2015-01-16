aws_resource_tag node['ec2']['instance_id'] do
  tags({
      "Name"        => "OpsWorks Production Stack",
      "Environment" => node.chef_environment
    })
  action :update
end

include_recipe "route53"

node['aws']['route53']['entries'].each do | entry |
  route53_record "create a record" do
    name  entry.name
    type  entry.type
    alias_target "dualstack." + entry.alias_target
    zone_id               entry.zone_id
    aws_access_key_id     node['aws']['route53']['aws_access_key_id']
    aws_secret_access_key node['aws']['route53']['aws_secret_access_key']
    routing_policy entry.routing_policy
    failover_record_type entry.failover_record_type
    set_id entry.name + "-" + entry.failover_record_type
    evaluate_target_health entry.evaluate_target_health
    associate_with_health_check entry.associate_with_health_check
    overwrite true
    action :create
  end
end
