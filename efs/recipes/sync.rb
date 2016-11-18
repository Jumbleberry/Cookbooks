# Create swarm repo private key
file node['swarm']['ssh_key'] do
  owner 'root'
  group 'root'
  mode '0400'
  content node['swarmAppSshKey']
  action :create_if_missing
end

# Sync swarm repo from Github
execute "sync-swarm-repo" do
    cwd node['swarm']['path']
    command "ssh-agent bash -c 'ssh-add #{node['swarm']['ssh_key']}; git clone -b #{node['swarm']['revision']} git@#{node['swarm']['url']}'"
    user 'root'
end

# Create integration repo private key
file node['integration']['ssh_key'] do
  owner 'root'
  group 'root'
  mode '0400'
  content node['integrationAppSshKey']
  action :create_if_missing
end

# Sync integration repo from Github
execute "sync-integration-repo" do
    cwd node['integration']['path']
    command "ssh-agent bash -c 'ssh-add #{node['integration']['ssh_key']}; git clone -b #{node['integration']['revision']} git@#{node['integration']['url']}'"
    user 'root'
end