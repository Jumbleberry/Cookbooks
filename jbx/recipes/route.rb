# Set the branch to checkout
branch = ENV['JBX_MESH_BRANCH'] || node['jbx']['route']['branch']

git node['jbx']['route']['path'] do
  if !node['jbx']['route']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['route']['github_key'] + "_wrapper.sh"
  end
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

      "hitpath_host"            => node['jbx']['credentials']['hitpath']['host'],
      "hitpath_username"        => node['jbx']['credentials']['hitpath']['username'],
      "hitpath_password"        => node['jbx']['credentials']['hitpath']['password'],
      "hitpath_database"        => node['jbx']['credentials']['hitpath']['dbname'],

      "redis_host"              => node['jbx']['credentials']['redis']['host'],
      "redis_port"              => node['jbx']['credentials']['redis']['port'],

      "crypt"                   => node['jbx']['credentials']['crypt'],
      "raygun"                  => node['jbx']['credentials']['raygun']
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
