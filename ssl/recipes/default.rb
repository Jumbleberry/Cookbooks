include_recipe "apt"
include_recipe "awscli"

# System packages
syspackages = ['git', 'gcc', 'vim', 'libpcre3-dev', 'make', 'curl', 'unzip', 'uuid']
syspackages.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

# Install packages
packages = node['ssl']['packages']
packages.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
  end
end

# Fix module object has no attribute warnings
execute "pip-upgrade-requests" do
    command 'pip install --upgrade requests'
    user 'root'
end

# Pull letsencrypt-aws repo from Github
git "#{Chef::Config[:file_cache_path]}" do
  repository node['letsencrypt_aws_github_url']
  revision 'master'
  action :sync
end

# Install letencrypt-aws
execute "install-letencrypt-aws" do
    cwd "#{Chef::Config[:file_cache_path]}/letsencrypt-aws"
    command <<-EOF
        pip install -U pip
        pip install flake8
        pip install -r requirements.txt
        EOF
    user 'root'
end

# Pin cryptography to 1.2.1 to avoid enterypoint error
# May not need this in the future if letsencrypt-aws release patch
execute "pin-cryptography" do
    command 'pip install cryptography==1.2.1'
    user 'root'
end

# Make sure we have private key for ACME server
# Make sure AWS credentials are configured (aws_access_key_id, aws_secret_access_key and aws_region)
# Set environment variables for letsencrypt-aws
 
# Run letsencrypt-aws
# If the certificate is not expiring soon, but you need to issue a new one anyways, the --force-issue flag can be provided
execute "run-letsencrypt-aws" do
    cwd "#{Chef::Config[:file_cache_path]}/letsencrypt-aws"
    command 'python letsencrypt-aws.py update-certificates --force-issue'
    user 'root'
end