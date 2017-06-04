require 'resolv'

node[:opsworks][:stack] = search("aws_opsworks_stack").first
node[:opsworks][:layers] = search("aws_opsworks_layer").first
node[:opsworks][:instance] = search("aws_opsworks_instance").first

template '/etc/hosts' do
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => node[:opsworks][:instance][:hostname],
    :nodes => search(:node, "name:*")
  )
end
