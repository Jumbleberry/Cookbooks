include_recipe "jbx::core"
include_recipe "jb_deploy::mail"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['mail']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['mail']['hostname']

template virtualhost do
  source    "nginx/processing.erb"
  variables ({
    "hostname"          => node['jbx']['mail']['hostname'],
    "path"              => "#{node['jbx']['core']['path']}/public",
    "resources_path"    => "#{node['jbx']['core']['path']}/application/modules/mail/resources"
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