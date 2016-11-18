# Create swarm repo private key
file node['swarm']['ssh_key'] do
  owner 'root'
  group 'root'
  mode '0755'
  content node['swarmAppSshKey']
  action :create_if_missing
end

# Sync swarm repo from Github
git node['swarm']['path'] do
  repository node['swarm']['url']
  revision node['swarm']['revision']
  ssh_wrapper "ssh -i #{node['swarm']['ssh_key']}"
  user 'root'
  action :sync
end

# Create integration repo private key
file node['integration']['ssh_key'] do
  owner 'root'
  group 'root'
  mode '0755'
  content node['integrationAppSshKey']
  action :create_if_missing
end

# Sync integration repo from Github
git node['integration']['path'] do
  repository node['integration']['url']
  revision node['integration']['revision']
  ssh_wrapper "ssh -i #{node['integration']['ssh_key']}"
  user 'root'
  action :sync
end