include_recipe "apt"
include_recipe "awscli"

# Set default AWS region
ENV['AWS_DEFAULT_REGION'] = node['awsRegion']

# Register the instance
execute "register-targets" do
    command <<-EOF
        instanceId=$(wget -q -O - #{node['metadata_instance_id_url']})
        aws elbv2 register-targets --target-group-arn #{node['nginxElbTargetArn']} --targets Id=$instanceId
        EOF
    user 'root'
end