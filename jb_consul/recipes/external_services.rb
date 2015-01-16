cron_path = node["consul"]["config_dir"]

# Reset AWS Tags
# If tag elements are present, and this is on EC2
# We reset the bootstrap tag here to get the cron to reload the consul configuration
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

#Copy the cron script to the consul configuration folder
template "#{cron_path}/consul_cron.php" do
    source "consul_cron.php.erb"
    owner "root"
    group "root"
    variables({
        :external_services => node['jb_consul']['external_services'].to_json
    })
end