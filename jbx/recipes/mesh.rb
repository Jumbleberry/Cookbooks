include_recipe "jbx::core"
include_recipe "deploy::mesh"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['mesh']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['mesh']['hostname']

template virtualhost do
  source    "nginx/mesh.erb"
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
