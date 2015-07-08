include_recipe "nginx"
include_recipe "web-server"
include_recipe "titan::deploy"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['titan']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['titan']['hostname']

template virtualhost do
  source    "nginx/titan.erb"
  variables ({
    "hostname"          => node['titan']['hostname'],
    "path"              => "#{node['titan']['path']}/build"
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