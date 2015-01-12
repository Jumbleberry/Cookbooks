# Import the deployment key to unencrypt the contents
key_name            = 'aws_deploy_key.key'
key_base64_string   = node['aws_deploy_key']

# Creates gpg directory
directory '/root/.gnupg' do
    owner "root"
    group "root"
end

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