include_recipe "phalcon"
include_recipe "nginx"
include_recipe "jb_redis"
include_recipe "jb_deploy::core"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['api']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['api']['hostname']

template virtualhost do
  source    "nginx/api.erb"
  variables ({
    "hostname"  => node['jbx']['api']['hostname'],
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

if node['admin']['environment'] == 'development'
    # Create host entry for database
    execute "create-db-host-entry" do
        command "echo \"\n#{node['vagrant']['jb-db']} #{node['jbx']['credentials']['mysql_write']['host']}\n\" >> /etc/hosts"
        user "root"
    end
end