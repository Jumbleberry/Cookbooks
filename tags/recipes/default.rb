
# If tag elements are present, and this is on EC2
if ( node.attribute?('ec2') && node.attribute?('aws') && node['aws'].attribute?('tags') )
    
    node['aws']['tags'].each_with_index { |val, index|
        
        aws_resource_tag node['ec2']['instance_id'] do
          aws_access_key node['aws']['aws_access_key_id']
          aws_secret_access_key node['aws']['aws_secret_access_key']
          tags(
              node['aws']['tags'][index]
          )
          action index
        end
    }
end