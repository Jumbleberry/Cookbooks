include_recipe "awscli"

# Install NFS client
package "nfs-common" do
    action :install
end

# Get AWS region
execute "get-aws-region" do
    command "awsRegion=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')"
end

# Get the file system ID
efsName = 'Campaigns'
execute "get-file-system-id" do
    command "fileSystemId=$(aws efs --region $awsRegion describe-file-systems | grep -iC 5 '\"Name\":\s\"{efsName}\"' | grep -ioP '(?<=FileSystemId\":\s\")[^\"]*' )"
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
  command "mount -t nfs4 -o vers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$fileSystemId.efs.$awsRegion.amazonaws.com:/ {efsMountPoint}"
  user 'root'
end