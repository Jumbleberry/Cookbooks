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
    mode '0444'
    action :create
end

# Mount EFS
execute "mount-efs" do
    command <<-EOF
        awsRegion=$(curl -s #{node['instance_identity_url']} | grep -ioP '#{node['region_reg']}')
        fileSystemId=$(aws efs --region $awsRegion describe-file-systems | grep -iC 5 '#{node['efs_name_reg']}' | grep -ioP '#{node['file_system_id_reg']}')
        mount -t nfs4 -o vers=4.1 $(curl -s #{node['availability_zone_url']}).$fileSystemId.efs.$awsRegion.amazonaws.com:/ #{node['efs_mount_point']}
        EOF
    user 'root'
end