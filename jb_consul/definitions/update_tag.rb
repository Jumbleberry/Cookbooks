define :update_tag, :instance_id => '',:tag_name => 'consul', :tag_value => 'bootstrap' do
    params[:instance_id] ||= params[:name]
    aws_resource_tag instance_id do
        aws_access_key node['aws']['aws_access_key_id']
        aws_secret_access_key node['aws']['aws_secret_access_key']
        tags (
            {params[:tag_name] => params[:tag_value]}
        )
        action :add
    end
end
