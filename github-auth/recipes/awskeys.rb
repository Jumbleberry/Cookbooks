path = node['github']['wrapper_path']
key_name = 'aws_deploy_key.key'
# Creates gpg directory
directory '/root/.gnupg' do
    owner "root"
    group "root"
end

# Import the deployment key to unencrypt the contents
key_base64_string = node['aws_deploy_key']

execute 'unencrypt key' do
    cwd "/root/.gnupg"
    command "echo '#{key_base64_string}' | sed -e 's/\\s\\+/\\n/g' | openssl base64 -d > #{key_name}"
end

# Add key to gpg key ring
execute "import gpg key" do
    cwd "/root/.gnupg"
    command "gpg --allow-secret-key-import --import #{key_name}"
    not_if "gpg --list-keys | grep deploy"
end

#Creates ssh folder for github keys
directory path do
  action :create
  owner username
  group username
  recursive true
end

#Get all the applications keys
apps = {}
#JBX
apps['core'] = node['jbx']['core']['github_key'];
apps['mesh'] = node['jbx']['mesh']['github_key'];
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
        command "gpg --output #{key}.key --decrypt #{key}.key.gpg"
        user "root"
        not_if do ::File.exists?("#{path}/#{key}.key") end
    end
end