# Packages
default['ssl']['packages'] = [
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
  }
]

# letsencrypt-aws config
default['letsencrypt_aws_github_url'] = 'https://github.com/alex/letsencrypt-aws.git'