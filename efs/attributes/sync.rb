# Swarm code
default['swarm']['path'] = node['efsMountPoint']
default['swarm']['url'] = 'git://github.com/Jumbleberry/Swarm.git'
default['swarm']['revision'] = 'master'
default['swarm']['ssh_key'] = ENV['HOME'] + '/swarm_github_key'

# Integration code
default['Integration']['path'] = node['efsMountPoint'] + '/integration'
default['Integration']['url'] = 'git://github.com/Jumbleberry/Campaign-Library.git'
default['Integration']['revision'] = 'swarm'
default['Integration']['ssh_key'] = ENV['HOME'] + '/integration_github_key'