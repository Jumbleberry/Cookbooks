include_recipe "aws_deploy"

path        = node['github-auth']['wrapper_path']

#Creates ssh folder for github keys
directory path do
  action :create
  owner "root"
  group "root"
  recursive true
end

if !node['github-auth']['keys'].empty?
    node['github-auth']['keys'].each do | key |
        #Move encrypted key file to destination folder
        cookbook_file "#{path}/#{key}.key.gpg" do
            source "ssh/#{key}.key.gpg"
            owner "root"
            group "root"
            mode "0664"
        end
    
        #Unencrypt key using the previosuly imported gpg key
        execute "unencrypt key: #{app}" do
            cwd path
            command "gpg --output #{key}.key --decrypt --batch --yes #{key}.key.gpg && chmod 0600 #{key}.key"
            user "root"
        end
    end
end