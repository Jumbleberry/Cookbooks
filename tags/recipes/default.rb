include_recipe "aws"
# If tag elements are present, and this is on EC2
if ( node.attribute?('ec2') && node[:ec2].attribute?('instance_id') && /(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]) &&
        node.attribute?('aws') && node['aws'].attribute?('tags') )
    
    node['aws']['tags'].each do |key, array|
        aws_resource_tag node['ec2']['instance_id'] do
          aws_access_key node['aws']['aws_access_key_id']
          aws_secret_access_key node['aws']['aws_secret_access_key']
          tags(
              node['aws']['tags'][key]
          )
          action key.to_sym
        end
    end
end