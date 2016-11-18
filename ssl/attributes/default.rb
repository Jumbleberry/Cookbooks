# Letsencrypt-aws config
default['letsencrypt_aws']['hosts'] = '["jbxstatic.com", "www.jbxstatic.com", "jbxswarm.com", "www.jbxswarm.com", "renewforskin.com", "m.renewforskin.com", "www.renewforskin.com"]'
default['letsencrypt_aws']['github_url'] = 'https://github.com/Hao-Jumbleberry/letsencrypt-aws.git'
default['letsencrypt_aws']['branch'] = 'elbv2'
default['letsencrypt_aws']['repo_path'] = '/var/www/letsencrypt-aws'
default['letsencrypt_aws']['acme_private_key'] = 'acme-private.pem'
default['letsencrypt_aws']['acme_account_key'] = 'file:///var/www/letsencrypt-aws/' + default['letsencrypt_aws']['acme_private_key']
default['letsencrypt_aws']['acme_directory_url'] = 'https://acme-v01.api.letsencrypt.org/directory'

# Build the config json object
default['letsencrypt_aws']['config'] = '{
    "domains": [
        {
            "elb": {
                "arn": "' + node['nginxElbArn'] + '",
                "port": "443"
            },
            "hosts": ' + default['letsencrypt_aws']['hosts'] + ',
            "key_type": "rsa"
        }
    ],
    "acme_account_key": "' + default['letsencrypt_aws']['acme_account_key'] + '",
    "acme_directory_url": "' + default['letsencrypt_aws']['acme_directory_url'] + '"
}'

# Packages
default['ssl']['packages'] = [
  { 
      "name" => "build-essential",
      "version" => "*"
  },
  { 
      "name" => "python-dev",
      "version" => "*"
  },
  { 
      "name" => "libffi-dev",
      "version" => "*"
  },
  { 
      "name" => "libssl-dev",
      "version" => "*"
  },
  { 
      "name" => "git",
      "version" => "*"
  }
]