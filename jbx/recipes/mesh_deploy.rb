include_recipe "github-auth"

# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['mesh']['branch']

git node['jbx']['mesh']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/mesh_wrapper.sh"
  repository node['jbx']['mesh']['git-url']
  revision branch
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['mesh']['path']}"
  user "root"
  action :run
end