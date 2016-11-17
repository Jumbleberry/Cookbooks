# AWS
default['availability_zone_url'] = 'http://169.254.169.254/latest/meta-data/placement/availability-zone'

# Packages
default['efs']['packages'] = [
  { 
      "name" => "nfs-common",
      "version" => "*"
  }
]

# Swarm code
default['swarm']['path'] = node['efsMountPoint']
default['swarm']['url'] = 'https://github.com/Jumbleberry/Swarm.git'
default['swarm']['revision'] = 'master'
default['swarm']['ssh_key'] = ENV['HOME'] + '/swarm_github_key'

# Integration code
default['integration']['path'] = node['efsMountPoint'] + '/integration'
default['integration']['url'] = 'https://github.com/Jumbleberry/Campaign-Library.git'
default['integration']['revision'] = 'swarm'
default['integration']['ssh_key'] = ENV['HOME'] + '/integration_github_key'