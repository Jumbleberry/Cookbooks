require 'resolv'

node.default[:opsworks] = node[:opsworks] || {}
node.default[:opsworks][:stack] = search("aws_opsworks_stack").first
node.default[:opsworks][:layers] = search("aws_opsworks_layer")
node.default[:opsworks][:instance] = search("aws_opsworks_instance").first

template '/etc/hosts' do
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => node[:opsworks][:instance][:hostname]
  )
end
