define :fetch_instances_by_tag, :tag_name => 'consul', :tag_value => 'bootstrap' do
    params[:tag_name] ||= params[:name]
    stack_file = node['jb_consul']['stack_file']
    stack_file_path = node['jb_consul']['stack_file_path']

    if node.has_key?("ec2")
        check_consul_bootstrap = "aws ec2 describe-instances --filters 'Name=tag:#{params[:tag_name]},Values=#{params[:tag_value]}' > #{stack_file}"
        execute check_consul_bootstrap do
            cwd stack_file_path
        end
    end
end
