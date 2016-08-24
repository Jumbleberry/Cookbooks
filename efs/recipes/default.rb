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
execute "get-aws-region" do
    environment => {
      'efsName' => 'Campaigns',
      'efsMountPoint' => efsMountPoint
    }
    command <<-EOH
        awsRegion=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
        fileSystemId=$(aws efs --region $awsRegion describe-file-systems | grep -iC 5 '\"Name\":\s\"${efsName}\"' | grep -ioP '(?<=FileSystemId\":\s\")[^\"]*' )
        mount -t nfs4 -o vers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$fileSystemId.efs.$awsRegion.amazonaws.com:/ ${efsMountPoint}
    EOH
    user 'root'
end