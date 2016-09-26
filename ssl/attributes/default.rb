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

# Letsencrypt-aws config
default['letsencrypt_aws']['github_url'] = 'https://github.com/Hao-Jumbleberry/letsencrypt-aws.git'
default['letsencrypt_aws']['branch'] = 'elbv2'
default['letsencrypt_aws']['repo_path'] = '/var/www/letsencrypt-aws'
default['letsencrypt_aws']['config'] = '{
    "domains": [
        {
            "elb": {
                "arn": "' + node['nginxElbArn'] + '",
                "port": "443"
            },
            "hosts": ["jbxstatic.com", "jbxswarm.com", "www.jbxstatic.com", "www.jbxswarm.com"],
            "key_type": "rsa"
        }
    ],
    "acme_account_key": "file:///var/www/letsencrypt-aws/acme-private.pem",
    "acme_directory_url": "https://acme-v01.api.letsencrypt.org/directory"
}'