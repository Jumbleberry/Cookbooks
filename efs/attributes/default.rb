# AWS
default['instance_identity_url'] = 'http://169.254.169.254/latest/dynamic/instance-identity/document'
default['availability_zone_url'] = 'http://169.254.169.254/latest/meta-data/placement/availability-zone'

# Config
default['efs_mount_point'] = '/html'

# Regex
default['region_reg'] = '(?<=region\"\s:\s\")[^\"]*'
default['efs_name_reg'] = '\"Name\":\s\"Campaigns\"'
default['file_system_id_reg'] = '(?<=FileSystemId\":\s\")[^\"\.]*'

# Packages
default['efs']['packages'] = [
  { 
      "name" => "nfs-common",
      "version" => "*"
  }
]