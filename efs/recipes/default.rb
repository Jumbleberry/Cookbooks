include_recipe "awscli"

# Install packages
packages = node['efs']['packages']
packages.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
  end
end

# Create the EFS mount point
efsMountPoint = node['efs_mount_point']
directory efsMountPoint do
    user 'www-data'
    group 'www-data'
    mode '0554'
    action :create
end

# Mount EFS
execute "mount-efs" do
    command <<-EOF
        mount -t nfs4 -o vers=4.1 $(curl -s #{node['availability_zone_url']}).#{node['fileSystemId']}.efs.#{node['awsRegion']}.amazonaws.com:/ #{node['efs_mount_point']}
        EOF
    user 'root'
end