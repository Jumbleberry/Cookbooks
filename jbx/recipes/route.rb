include_recipe "timezone-ii"
include_recipe "web-server"
include_recipe "github-auth"
include_recipe "nginx"
include_recipe "php"

# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['route']['branch']

git node['jbx']['route']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/" + "route_wrapper.sh"
  repository node['jbx']['route']['git-url']
  revision branch
  action :sync
  user 'root'
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['route']['path']}"
  user "root"
  action :run
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['route']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['route']['hostname']

template virtualhost do
  source    "nginx/route.jbx.jumbleberry.com.erb"
  variables ({
    "hostname"  => node['jbx']['route']['hostname'],
    "path"      => node['jbx']['route']['path']
  })
end

#Update application credentials
credentials_file = "#{node['jbx']['route']['path']}/settings/databases.ini"
credentials_file_template = "databases.ini.erb"

template credentials_file do
  source credentials_file_template
  variables ({
      "mysql_read_host"         => node['jbx']['credentials']['mysql_read']['host'],
      "mysql_read_username"     => node['jbx']['credentials']['mysql_read']['username'],
      "mysql_read_password"     => node['jbx']['credentials']['mysql_read']['password'],
      "mysql_read_database"     => node['jbx']['credentials']['mysql_read']['dbname'],
      "redis_host"              => node['jbx']['credentials']['redis']['host'],
      "redis_port"              => node['jbx']['credentials']['redis']['port'],
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
