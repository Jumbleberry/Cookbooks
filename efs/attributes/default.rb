# AWS
default['availability_zone_url'] = 'http://169.254.169.254/latest/meta-data/placement/availability-zone'

# Packages
default['efs']['packages'] = [
  { 
      "name" => "nfs-common",
      "version" => "*"
  }
]