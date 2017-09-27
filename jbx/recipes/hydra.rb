include_recipe "jbx::core"
include_recipe "jb_deploy::mesh"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/default'
virtualhost_link    = '/etc/nginx/sites-enabled/default'

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

template virtualhost do
  source    "nginx/hydra.erb"
  variables ({
    "path"      => "#{node['jbx']['core']['path']}/public"
  })
  notifies :reload, "service[nginx]", :delayed
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]", :delayed
end

# install dog-statsd dependency
execute '/usr/local/openresty/luajit/bin/luarocks install lua-resty-dogstatsd'