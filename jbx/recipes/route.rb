include_recipe "nginx"
include_recipe "jb_consul"
include_recipe "deploy::route"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['route']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['route']['hostname']

template virtualhost do
  source    "nginx/route.erb"
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
  notifies :reload, "service[nginx]"
end