include_recipe "aws"
include_recipe "awscli"
include_recipe "tags"
include_recipe "web-server"
include_recipe "php"

# Create lib directory for consul
directory node['consul']['lib_dir'] do
  recursive true
  owner 'root'
  group 'root'
  action :create
end

# Install consul ui if we're supposed to serve it
if (node['consul'].attribute?('serve_ui') && node['consul']['serve_ui'])
    include_recipe "consul::ui"
end

include_recipe "consul"
include_recipe "dnsmasq"


cron_path = node["consul"]["config_dir"]

# Create cluster group
group "cluster" do
  action :create
  members ["root"]
  append true
end

# Turn off the existing consul service
service "consul" do
  case node['platform']
  when 'ubuntu'
    if node['consul']['init_style'] == 'systemd'
      provider Chef::Provider::Service::Systemd
    elsif node['lsb']['codename'] == 'trusty'
      provider Chef::Provider::Service::Upstart
    end
  end
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :stop
end
   
# Remove consul files
directory node['consul']['data_dir'] do
  recursive true
  action :delete
end

# Recreate the directory if necessary
directory node['consul']['data_dir'] do
  recursive true
  owner 'root'
  group 'root'
  action :create
end

# Reset AWS Tags
# If tag elements are present, and this is on EC2
if ( node.attribute?('ec2') && node[:ec2].attribute?('instance_id') && /(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]) &&
        node.attribute?('aws') && node['aws'].attribute?('tags') )
    
    aws_resource_tag node['ec2']['instance_id'] do
        aws_access_key node['aws']['aws_access_key_id']
        aws_secret_access_key node['aws']['aws_secret_access_key']
        tags({
            "consul" => "bootstrap"
        })
        action :update
    end
end

if node['environment'] == 'development'
    # Configuration for gearman service
    template "#{cron_path}/gearman.json" do
        source "gearman.json.erb"
        owner "root"
        group "root"
    end
end

# Turn consul back on
service "consul" do
  action :start
end

#Copy the cron script to the consul configuration folder
template "#{cron_path}/consul_cron.php" do
    source "consul_cron.php.erb"
    owner "root"
    group "root"
    variables({
        :external_services => node['jb_consul']['external_services'].to_json
    })
end

#Add the cron helper libraries to the consul config folder
remote_directory "#{cron_path}/JbServerHelpers" do
    source "JbServerHelpers"
    files_mode "0664"
    owner "root"
    group "root"
    mode "0775"
end

# Create Helpers data directory so it can be used by the templates
directory "#{cron_path}/JbServerHelpers/data" do
  owner "root"
  group "root"
end

# Copy the mocked_stack script for non-production environments
ip = node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
template "#{cron_path}/JbServerHelpers/data/mocked_stack.json" do
    source "mocked_stack.json.erb"
    owner "root"
    group "root"
    variables({
        :ip          => ip,
        :environment => node['environment']
    })
end

#Run consul cron job
cron "Consul cron" do
  command "/usr/bin/php #{cron_path}/consul_cron.php"
  user "root"
  action :create
end

# Run the cron
execute "/usr/bin/php #{cron_path}/consul_cron.php &" do
    user "root"
end
