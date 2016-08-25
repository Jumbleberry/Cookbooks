include_recipe "awscli"

# Install NFS client
package "nfs-common" do
    action :install
end

# Create the EFS mount point
efsMountPoint = '/html'
directory efsMountPoint do
    user 'www-data'
    group 'www-data'
    mode '0444'
    action :create
end

# Mount EFS
execute "mount-efs" do
    command <<-EOF
        awsRegion=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -ioP "#{node['region_regex']}")
        EOF
    user 'root'
end