define :fetch_instances_by_tag, :tag_name => 'consul', :tag_value => 'bootstrap' do
    params[:tag_name] ||= params[:name]
    region = node['aws']['region']

#    if node.has_key?("ec2")
    ruby_block "get instances " + params[:tag_value] do
        block do
            ENV['HOME'] = node[:etc][:passwd][node['user']][:dir]
            some_var = `aws --region #{region} --profile default ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}'`
            node.override['jb_consul']['instances'][params[:tag_value]] = JSON.parse(some_var || '{"Reservations": []}')
            `aws --region #{region} --profile default ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}' > /tmp/test.json`
            `echo "aws --region #{region} --profile default ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}'" > /tmp/test2.json`
        end
        action :run
    end
#    end
end
