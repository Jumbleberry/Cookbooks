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
    environment ({
      'efsNameRegex' => %Q{\"Name\":\s\"Campaigns\"},
      'efsMountPoint' => efsMountPoint
    })
    command <<-EOF
        awsRegion=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
        EOF
    user 'root'
end