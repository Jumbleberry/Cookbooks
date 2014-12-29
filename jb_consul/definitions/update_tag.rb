define :update_tag, :tag_name => 'consul', :tag_value => 'bootstrap' do
    instance = params[:name]
    aws_resource_tag instance do
        aws_access_key node['aws']['aws_access_key_id']
        aws_secret_access_key node['aws']['aws_secret_access_key']
        tags (
            {params[:tag_name] => params[:tag_value]}
        )
        action :update
    end
end
