include_recipe "jbx::core"
include_recipe "jb_deploy::mesh"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['mesh']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['mesh']['hostname']

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

template virtualhost do
  source    "nginx/mesh.erb"
  variables ({
    "hostname"  => node['jbx']['mesh']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public"
  })
  notifies :reload, "service[nginx]", :delayed
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]", :delayed
end
