include_recipe "jbx::core"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['processing']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['processing']['hostname']

template virtualhost do
  source    "nginx/processing.erb"
  variables ({
    "hostname"  => node['jbx']['processing']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public"
  })
end

template "#{node['jbx']['processing']['path']}/config/config.json" do
    source "processing/config.json.erb"
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end
