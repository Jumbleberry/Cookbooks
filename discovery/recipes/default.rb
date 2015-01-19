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
    zone_id entry.zone_id
    
    if !entry['target'].nil?
      aliasTarget = {
        :hosted_zone_id         => entry.hosted_zone_id,
        :dns_name               => entry.target,
        :evaluate_target_health => entry.evaluate_target_health,
      }         
      
      alias_target aliasTarget
    else
      value entry.value
    end    
    
    if !entry['failover_record_type'].nil?
      routingPolicy = {
        :failover       => entry.failover_record_type,
        :set_identifier => entry.failover_record_type + "-" + entry.name
      }       
      
      routing_policy routingPolicy
    end
    
    aws_access_key_id     node['aws']['route53']['aws_access_key_id']
    aws_secret_access_key node['aws']['route53']['aws_secret_access_key']            
    overwrite true
    action :create
  end      
end
