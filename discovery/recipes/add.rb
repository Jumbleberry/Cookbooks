# Ensure we are on AWS
if ( node.attribute?('ec2') && node[:ec2].attribute?('instance_id') && /(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]) &&
        node.attribute?('aws') && node['aws'].attribute?('route53') )

  include_recipe "route53"
  node[:opsworks][:stack] = search("aws_opsworks_stack").first
  node[:opsworks][:layers] = search("aws_opsworks_layer").first
  node[:opsworks][:instance] = search("aws_opsworks_instance").first

  layerIps = []

  # Add all IPs
  node[:opsworks][:instance][:layers].each do | shortname |
    node[:opsworks][:layers][shortname][:instances].each do | instanceshortname, instance |
      publicIp = instance[:elastic_ip].nil?? instance[:ip]: instance[:elastic_ip]
      status   = node[:opsworks][:layers][shortname][:instances][instanceshortname][:status]

      if status == "online"
        layerIps.push(publicIp)
      end
    end
  end

  if node['aws']['route53']['instance_destroy'] == false
    layerIps.push(node['route53']['instanceIp'])
  else
    layerIps.delete(node['route53']['instanceIp'])
  end

  layerIps = layerIps.uniq

  node['aws']['route53']['entries'].each do | domain, entries |
    entries.each do | entry |
      route53_record "create a record" do
        name  domain
        type  entry.type
        # Zone ID is the Route 53 Hosted Zone
        zone_id entry.zone_id

        # Check for TTL
        if !entry['ttl'].nil?
          ttl entry['ttl']
        else
          ttl node['aws']['route53']['defaults']['ttl']
        end

        # Is it an alias record?
        if !entry['target'].nil?
          # Hosted Zone ID is the ID of the ELB
          aliasTarget = {
            :hosted_zone_id         => entry.hosted_zone_id,
            :dns_name               => entry.target,
            :evaluate_target_health => entry.evaluate_target_health,
          }

          alias_target aliasTarget
        # Is there a specific IP?
        elsif !entry['value'].nil?
          value entry['value']
        # Are there layer IPs?
        elsif !layerIps.empty?
          value layerIps
        # Default to instance IP
        else
          value default['route53']['instanceIp']
        end

        # Is there a failover?
        if !entry['failover_record_type'].nil?
          routingPolicy = {
            :failover       => entry.failover_record_type,
            :set_identifier => entry.failover_record_type + "-" + domain
          }

          routing_policy routingPolicy
        end

        # Is there a health check?
        if !entry['health_check_id'].nil?
          health_check_id entry['health_check_id']
        end

        aws_access_key_id     node['aws']['aws_access_key_id']
        aws_secret_access_key node['aws']['aws_secret_access_key']
        overwrite true
        action :create
      end
    end
  end
end