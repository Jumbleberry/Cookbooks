# System
default['instance_identity_url'] = 'http://169.254.169.254/latest/dynamic/instance-identity/document'
default['availability_zone_url'] = 'http://169.254.169.254/latest/meta-data/placement/availability-zone'
# Config
default['efs_mount_point'] = '/html'

# Regex
default['region_regex'] = '(?<=region\" : \")[^\"]*'