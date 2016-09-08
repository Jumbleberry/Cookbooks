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

# Fix module object has no attribute warnings
execute "pip-upgrade-requests" do
    command 'pip install --upgrade requests'
    user 'root'
end

# Pull letsencrypt-aws repo from Github
git node['letsencrypt_aws']['repo_path'] do
  repository node['letsencrypt_aws']['github_url']
  revision 'master'
  action :sync
end

# Install letencrypt-aws
execute "install-letencrypt-aws" do
    cwd "#{node['letsencrypt_aws']['repo_path']}/#{node['letsencrypt_aws']['repo_name']}"
    command <<-EOF
        python -m pip install virtualenv
        python -m virtualenv .venv
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
execute "export-letsencrypt-aws-config" do
    command <<-EOF
        export LETSENCRYPT_AWS_CONFIG='{
            "domains": [
                {
                    "elb": {
                        "name": "#{node['elb']['name']}",
                        "port": "443"
                    },
                    "hosts": #{node['elb']['hosts']},
                    "key_type": "rsa"
                }
            ],
            "acme_account_key": "#{node['acme']['account_key']['staging']}",
            "acme_directory_url": "#{node['acme']['directory_url']['staging']}"
        }'
        EOF
    user 'root'
end
 
# Run letsencrypt-aws
# If the certificate is not expiring soon, but you need to issue a new one anyways, the --force-issue flag can be provided
# execute "run-letsencrypt-aws" do
#     cwd "#{node['letsencrypt_aws']['repo_path']}/#{node['letsencrypt_aws']['repo_name']}"
#     command 'python letsencrypt-aws.py update-certificates --force-issue'
#     user 'root'
# end