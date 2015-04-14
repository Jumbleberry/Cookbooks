include_recipe "timezone-ii"
include_recipe "web-server"
include_recipe "nginx"
include_recipe "php"
include_recipe "zend"
include_recipe "s3fs-fuse"
include_recipe "admin::deploy"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['admin']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['admin']['hostname']

template virtualhost do
  source    "nginx/admin.jumbleberry.com.erb"
end

#Nginx service
service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end
