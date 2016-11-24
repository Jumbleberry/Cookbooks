# Create swarm repo private key
file node['swarm']['ssh_key'] do
  owner 'root'
  group 'root'
  mode '0400'
  content node['swarmAppSshKey']
  action :create_if_missing
end

# Clone swarm repo from Github if none exist
execute "clone-swarm-repo" do
    cwd node['swarm']['path']
    command "ssh-agent bash -c 'ssh-add #{node['swarm']['ssh_key']}; git clone -b #{node['swarm']['revision']} git@#{node['swarm']['url']} .'"
    not_if { ::File.directory?("#{node['swarm']['path']}/.git") }
    user 'root'
end

# Sync swarm repo from Github
execute "sync-swarm-repo" do
    cwd node['swarm']['path']
    command "ssh-agent bash -c 'ssh-add #{node['swarm']['ssh_key']}; git pull git@#{node['swarm']['url']} #{node['swarm']['revision']}'"
    only_if { ::File.directory?("#{node['swarm']['path']}/.git") }
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

# Clone integration repo from Github if none exist
execute "clone-integration-repo" do
    cwd node['integration']['path']
    command "ssh-agent bash -c 'ssh-add #{node['integration']['ssh_key']}; git clone -b #{node['integration']['revision']} git@#{node['integration']['url']} #{node['integration']['name']}'"
    not_if { ::File.directory?("#{node['integration']['path']}/#{node['integration']['name']}/.git") }
    user 'root'
end

# Sync integration repo from Github
execute "sync-integration-repo" do
    cwd node['integration']['path'] + '/' + node['integration']['name']
    command "ssh-agent bash -c 'ssh-add #{node['integration']['ssh_key']}; git pull git@#{node['integration']['url']} #{node['integration']['revision']}'"
    only_if { ::File.directory?("#{node['integration']['path']}/#{node['integration']['name']}/.git") }
    user 'root'
end