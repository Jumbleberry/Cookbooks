include_recipe "jbx::core"
include_recipe "jb_deploy::titan"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['titan']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['titan']['hostname']

template virtualhost do
  source    "nginx/titan.erb"
  variables ({
    "hostname"  => node['jbx']['titan']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public",
    "resources_path" => "#{node['jbx']['core']['path']}/application/modules/titan/resources"
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