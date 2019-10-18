include_recipe "jbx::core"
include_recipe "jb_deploy::hydra"

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
execute '/usr/local/openresty/luajit/bin/luarocks install lua-resty-dogstatsd' do
    notifies :reload, "service[nginx]", :delayed
end

# install filebeat
filebeat_install 'default'

filebeat_config 'default' do
  config node['filebeat']['hydra']['config']
end

node['filebeat']['hydra']['prospectors'].each do |p_name, p_config|
  filebeat_prospector p_name do
    config p_config
  end
end

filebeat_service 'default' do 
  disable_service true
end