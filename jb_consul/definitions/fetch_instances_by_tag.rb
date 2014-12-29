define :fetch_instances_by_tag, :tag_name => 'consul', :tag_value => 'bootstrap' do
    params[:tag_name] ||= params[:name]
    stack_file = node['jb_consul']['stack_file']
    stack_file_path = node['jb_consul']['stack_file_path']
    region = node['aws']['region']

#    if node.has_key?("ec2")
        execute "Describe EC2 Instances Test" + params[:tag_value] do
            command "aws --region #{region} --profile default ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}' --debug"
            user node['user']
        end
        
        execute "Describe EC2 Instances " + params[:tag_value] do
            command "aws --region #{region} --profile default ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}' > #{stack_file_path}#{stack_file}"
            user node['user']
        end
#    end
end
