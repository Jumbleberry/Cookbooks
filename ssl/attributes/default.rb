# Letsencrypt-aws config
default['letsencrypt_aws']['hosts'] = '[
    "jbxstatic.com", "m.jbxstatic.com", "www.jbxstatic.com", 
    "jbxswarm.com", "m.jbxswarm.com", "www.jbxswarm.com", 
    "renewforskin.com", "m.renewforskin.com", "www.renewforskin.com", "tablet.renewforskin.com",
    "buyroyaltyskin.com", "m.buyroyaltyskin.com", "www.buyroyaltyskin.com", "tablet.buyroyaltyskin.com",
    "skindermarewind.com", "m.skindermarewind.com", "www.skindermarewind.com", "tablet.skindermarewind.com",
    "try-oveena.com", "m.try-oveena.com", "www.try-oveena.com", "tablet.try-oveena.com",
    "trytendermaskin.com", "m.trytendermaskin.com", "www.trytendermaskin.com", "tablet.trytendermaskin.com",
    "discountedgarcinia.com", "www.discountedgarcinia.com",
    "genuine-garcinia.com", "www.genuine-garcinia.com",
    "tryevantiskincream.com", "m.tryevantiskincream.com", "www.tryevantiskincream.com", "tablet.tryevantiskincream.com"
]'
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
