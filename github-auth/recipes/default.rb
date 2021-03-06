# If this is on aws, then run the awskeys auth
if node.attribute?('aws_deploy_key')
    include_recipe "github-auth::awskeys"
end

#Creates tmp ssh folder for github keys
tmp_ssh_folder = node['github-auth']['wrapper_path']

directory tmp_ssh_folder do
  action :create
  owner 'root'
  group 'root'
  recursive true
end

#Creates one key file and ssh wrapper for each app
if !node['github-auth']['keys'].empty?
    node['github-auth']['keys'].each do |github_key|
        if !github_key.empty?
            key_name = github_key
            ssh_wrapper_name = github_key + "_wrapper.sh"
    
            if( !node.attribute?('aws_deploy_key') )
                #Copy private key to tmp folder
                cookbook_file "#{tmp_ssh_folder}/#{key_name}.key" do
                    source "ssh/#{key_name}.key"
                    owner 'root'
                    mode "0600"
                end
            end
    
            #Creates ssh wrapper for the key
            template "#{tmp_ssh_folder}/#{ssh_wrapper_name}" do
                source 'ssh/ssh_wrapper.sh.erb'
                variables ({
                    'tmp_key_file' => "#{tmp_ssh_folder}/#{key_name}.key"
                })
                mode "0770"
                owner 'root'
                group 'root'
            end
        end
    end
end