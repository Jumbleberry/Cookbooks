node[:opsworks] = node[:opsworks] || {}
node[:opsworks][:stack] = search("aws_opsworks_stack").first
node[:opsworks][:layers] = search("aws_opsworks_layer").first
node[:opsworks][:instance] = search("aws_opsworks_instance").first

os_release =
  if rhel7?
    os_release = File.read("/etc/redhat-release").chomp
  else
    `head -1 /etc/issue | sed -e 's/ \\\\.*//'`.chomp
  end

template "/etc/motd.opsworks-static" do
  source "motd.erb"
  mode "0644"
  variables({
    :stack => node[:opsworks][:stack],
    :layers => node[:opsworks][:layers],
    :instance => node[:opsworks][:instance],
    :os_release => os_release
  })
end
