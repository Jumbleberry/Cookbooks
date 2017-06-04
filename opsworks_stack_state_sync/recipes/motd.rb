node.default[:opsworks] = node[:opsworks] || {}
node.default[:opsworks][:stack] = search("aws_opsworks_stack").first
node.default[:opsworks][:layers] = search("aws_opsworks_layer")
node.default[:opsworks][:instance] = search("aws_opsworks_instance").first

template "/etc/motd.opsworks-static" do
  source "motd.erb"
  mode "0644"
  variables({
    :stack => node[:opsworks][:stack],
    :layers => node[:opsworks][:layers],
    :instance => node[:opsworks][:instance],
    :os_release => node[:lsb][:release]
  })
end
