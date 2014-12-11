#Nginx package
package 'nginx' do
  action :install
end

template '/etc/nginx/nginx.conf' do
  source    "nginx.conf.erb"
  variables ({
    "worker_processes" => node['nginx']['worker_processes'],
    "worker_connections" => node['nginx']['worker_connections']
  })
end

#Removes the default virtual host if exists
file '/etc/nginx/sites-available/default' do
  action :delete
end
link '/etc/nginx/sites-enabled/default' do
  action :delete
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [ :enable, :start ]
end