include_recipe "apt"
include_recipe "awscli"

# Install packages
packages = node['ssl']['packages']
packages.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
  end
end

# Pull letsencrypt-aws repo from Github
git node['letsencrypt_aws']['repo_path'] do
  repository node['letsencrypt_aws']['github_url']
  revision 'master'
  action :sync
  notifies :run, 'execute[pip-upgrade-requests]', :immediate
  notifies :run, 'execute[install-letencrypt-aws]', :immediate
  notifies :run, 'execute[pin-cryptography]', :immediate
end

# Fix module object has no attribute warnings
execute "pip-upgrade-requests" do
    cwd node['letsencrypt_aws']['repo_path']
    command 'sudo pip install --upgrade requests'
    user 'root'
    action :nothing
end

# Install letencrypt-aws
execute "install-letencrypt-aws" do
    cwd node['letsencrypt_aws']['repo_path']
    command <<-EOF
        python -m pip install virtualenv
        python -m virtualenv .venv
        pip install -U pip
        pip install flake8
        sudo pip install -r requirements.txt
        EOF
    user 'root'
    action :nothing
end

# Pin cryptography to 1.2.1 to avoid enterypoint error
# May not need this in the future if letsencrypt-aws releases patch
execute "pin-cryptography" do
    cwd node['letsencrypt_aws']['repo_path']
    command 'pip install cryptography==1.2.1'
    user 'root'
    action :nothing
end

# Set default AWS region (not sure if we need this if IAM role is properly configured)
ENV['AWS_DEFAULT_REGION'] = node['awsRegion']

# Set environment variables for letsencrypt-aws
ENV['LETSENCRYPT_AWS_CONFIG'] = node['letsencrypt_aws']['config']

# Register ACME account (so we dont need to upload the private key)
execute "register-acme-account" do
    cwd node['letsencrypt_aws']['repo_path']
    command 'python letsencrypt-aws.py register swarm@jumbleberry.com > acme-private.pem'
    not_if { ::File.exists?("#{node['letsencrypt_aws']['repo_path']}/acme-private.pem") }
    user 'root'
end
 
# Run letsencrypt-aws
# If the certificate is not expiring soon, but you need to issue a new one anyways, the --force-issue flag can be provided
execute "run-letsencrypt-aws" do
    cwd node['letsencrypt_aws']['repo_path']
    command 'python letsencrypt-aws.py update-certificates'
    user 'root'
end

# Set up weekly cron to auto-renew certificates
cron "renew-ssl-certificate" do
  minute '0'
  hour '0'
  weekday '1'
  home node['letsencrypt_aws']['repo_path']
  environment ({"LETSENCRYPT_AWS_CONFIG" => "#{node['letsencrypt_aws']['config']}".delete!("\n"), "AWS_DEFAULT_REGION" => "#{node['awsRegion']}"})
  command "python $HOME/letsencrypt-aws.py update-certificates --force-issue"
  user 'root'
  action :create
end