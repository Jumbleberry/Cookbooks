include_recipe "awscli"

# Install packages
packages = node['efs']['packages']
packages.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
  end
end

# Create the EFS mount point if not exist
efsMountPoint = node['efsMountPoint']
directory efsMountPoint do
    user 'www-data'
    group 'www-data'
    mode '0755'
    action :create
    notifies :run, 'execute[mount-efs]', :immediate
end

# Mount EFS
execute "mount-efs" do
    command <<-EOF
        mount -t nfs4 -o vers=4.1 $(curl -s #{node['availability_zone_url']}).#{node['fileSystemId']}.efs.#{node['awsRegion']}.amazonaws.com:/ #{node['efsMountPoint']}
        EOF
    user 'root'
    action :nothing
end