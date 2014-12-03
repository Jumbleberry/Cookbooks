# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['mesh']['branch']

git node['jbx']['mesh']['path'] do
  if !node['jbx']['mesh']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['mesh']['github_key'] + "_wrapper.sh"
  end
  repository node['jbx']['mesh']['git-url']
  revision branch
  user node['jbx']['user']
  action :sync
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/mesh.jbx.jumbleberry.com'
virtualhost_link    = '/etc/nginx/sites-enabled/mesh.jbx.jumbleberry.com'

template virtualhost do
  source    "nginx/mesh.jbx.jumbleberry.com.erb"
  variables ({
    "hostname"  => node['jbx']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public"
  })
end

link virtualhost_link do
  to virtualhost
  notifies :restart, "service[nginx]", :delayed
end
