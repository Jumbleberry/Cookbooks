
# If tag elements are present, and this is on EC2
if ( node.attribute?('ec2') && node.attribute?('aws') && node['aws'].attribute?('tags') )
    
    node['aws']['tags'].each do |key, array|
        aws_resource_tag node['ec2']['instance_id'] do
          aws_access_key node['aws']['aws_access_key']
          aws_secret_access_key node['aws']['aws_secret_key']
          tags(
              node['aws']['tags'][key]
          )
          action key.to_sym
        end
    end
end