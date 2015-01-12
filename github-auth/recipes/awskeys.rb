include_recipe "aws_deploy"

path        = node['github']['wrapper_path']

#Creates ssh folder for github keys
directory path do
  action :create
  owner "root"
  group "root"
  recursive true
end

#Get all the applications keys
apps = {}
#JBX
apps['core'] = node['jbx']['core']['github_key'];
apps['mesh'] = node['jbx']['mesh']['github_key'];
apps['route'] = node['jbx']['route']['github_key'];
#Jb-Admin
apps['admin'] = node['admin']['github_key'];

apps.each do | app, key |
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