# Install NFS client
package "#nfs-common" do
    action :install
end

# Mount EFS
mountTargetDNS = 'us-east-1c.fs-8ac002c3.efs.us-east-1.amazonaws.com'
efsMountPoint = '/public'
execute "mount-efs" do
  command "mount -t nfs4 -o vers=4.1 {mountTargetDNS}:/ {efsMountPoint}"
  user 'root'
end