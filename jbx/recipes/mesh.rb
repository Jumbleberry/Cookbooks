include_recipe "jbx::core"

# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['mesh']['branch']

git node['jbx']['mesh']['path'] do
  if !node['jbx']['mesh']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['mesh']['github_key'] + "_wrapper.sh"
  end
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

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['mesh']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['mesh']['hostname']

template virtualhost do
  source    "nginx/mesh.jbx.jumbleberry.com.erb"
  variables ({
    "hostname"  => node['jbx']['mesh']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public"
  })
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end
