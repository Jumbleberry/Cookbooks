aws_resource_tag node['ec2']['instance_id'] do
  tags({
      "Name"        => "OpsWorks Production Stack",
      "Environment" => node.chef_environment
    })
  action :update
end