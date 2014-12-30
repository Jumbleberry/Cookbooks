# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['route']['branch']

git node['jbx']['route']['path'] do
  if !node['jbx']['route']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['route']['github_key'] + "_wrapper.sh"
  end
  repository node['jbx']['route']['git-url']
  revision branch
  user node['jbx']['user']
  action :sync
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/route.jbx.jumbleberry.com'
virtualhost_link    = '/etc/nginx/sites-enabled/route.jbx.jumbleberry.com'

template virtualhost do
  source    "nginx/route.jbx.jumbleberry.com.erb"
  variables ({
    "hostname"  => node['jbx']['route']['hostname'],
    "path"      => node['jbx']['route']['path']
  })
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]", :delayed
end
