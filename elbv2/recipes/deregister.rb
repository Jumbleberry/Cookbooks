include_recipe "apt"
include_recipe "awscli"

# Set default AWS region
ENV['AWS_DEFAULT_REGION'] = node['aws_default_region']

# Register the instance
execute "deregister-targets" do
    command <<-EOF
        instanceId=$(wget -q -O - http://instance-data/latest/meta-data/instance-id)
        targetGroupArn=$(aws elbv2 describe-target-groups | grep '#{node['elb_name']}' | grep -ioP '#{node['target_group_arn_reg']}')
        aws elbv2 deregister-targets --target-group-arn $targetGroupArn --targets Id=$instanceId
        EOF
    user 'root'
end