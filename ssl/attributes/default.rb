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
default['letsencrypt_aws']['github_url'] = 'https://github.com/alex/letsencrypt-aws.git'
default['letsencrypt_aws']['repo_path'] = '/var/www'
default['letsencrypt_aws']['repo_name'] = 'letsencrypt-aws'

# ACME config - staging
default['acme']['account_key']['staging'] = 'file:///var/www/letsencrypt-aws/acme-staging-private.pem'
default['acme']['directory_url']['staging'] = 'https://acme-staging.api.letsencrypt.org/directory'
# ACME config - production
default['acme']['account_key']['production'] = 'file:///var/www/letsencrypt-aws/acme-production-private.pem'
default['acme']['directory_url']['production'] = 'https://acme-v01.api.letsencrypt.org/directory'

# ElB config
default['elb']['name'] = 'secure-elb'
default['elb']['hosts'] = ["jbxstatic.com", "jbxswarm.com", "www.jbxstatic.com", "www.jbxswarm.com"]