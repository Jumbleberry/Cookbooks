define :fetch_instances_by_tag, :tag_name => 'consul', :tag_value => 'bootstrap' do
    params[:tag_name] ||= params[:name]
    region = node['aws']['region']

#    if node.has_key?("ec2")
    ruby_block "get instances " + params[:tag_value] do
        ENV['HOME'] = node[:etc][:passwd][node['user']][:dir]
        node.override['jb_consul']['instances'][params[:tag_value]] = JSON.parse(`echo '{"Reservations":[]}'` || {})
    end
#    end
end
