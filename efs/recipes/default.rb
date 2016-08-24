include_recipe "awscli"

# Install NFS client
package "nfs-common" do
    action :install
end

# Create the EFS mount point
# efsMountPoint = '/html'
# directory efsMountPoint do
#     user 'www-data'
#     group 'www-data'
#     mode '0444'
#     action :create
# end

# Mount EFS
# mountTargetDNS = 'us-east-1c.fs-8ac002c3.efs.us-east-1.amazonaws.com'
# execute "mount-efs" do
#   command "mount -t nfs4 -o vers=4.1 {mountTargetDNS}:/ {efsMountPoint}"
#   user 'root'
# end