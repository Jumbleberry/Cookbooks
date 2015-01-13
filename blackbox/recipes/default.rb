# Blackbox installation
# Based on https://github.com/k-kinzal/chef-php-phalcon
path  = node['blackbox']['path']
key_name = 'aws_deploy_key.key'

git path do
    repository node['blackbox']['git_url']
    reference node['blackbox']['git_ref']
    action :sync
end

#Create symlinks for the blackbox binaries
execute 'blackbox symlinks' do
    cwd "#{path}/bin"
    user "root"
    command "ln -s #{path}/bin/blackbox_* /usr/local/bin/"
end

execute 'blackbox symlinks includes' do
    cwd "#{path}/bin"
    user "root"
    command "ln -s #{path}/bin/_* /usr/local/bin/"
end

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
end

# Unecrypt blackbox contents
execute "blackbox post deply" do
    cwd ""
end