include_recipe "timezone-ii"
include_recipe "web-server"
include_recipe "github-auth"
include_recipe "nginx"
include_recipe "php"
include_recipe "zend"
include_recipe "s3fs-fuse"

# Make sure directory exists
# Use the same user defined for the admin application
directory node['admin']['path'] do
  owner node['admin']['user']
  group node['admin']['user']
end

branch = ENV['JB_ADMIN_BRANCH'] || node['admin']['branch']

git node['admin']['path'] do
  if !node['admin']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['admin']['github_key'] + "_wrapper.sh"
  end
  repository node['admin']['git-url']
  revision branch
  user 'root'
  action :sync
end

# Run the deploy script
execute 'Deploy Script' do
    cwd "#{node['admin']['path']}"
    user "root"
    command 'sh deploy.sh'
end

execute "chown-data-www" do
  command "chown -R #{node['admin']['user']}:#{node['admin']['user']} #{node['admin']['path']}"
  user "root"
  action :run
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['admin']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['admin']['hostname']

template virtualhost do
  source    "nginx/admin.jumbleberry.com.erb"
end

#Add application configurations
template "#{node['admin']['path']}/application/configs/application.ini" do
  source  "admin/application.ini.erb"
end

#Add cron configurations
template "#{node['admin']['path']}/cron_scripts/includes/config/settings.php" do
  source  "admin/settings.php.erb"
end

#Creates bucket directory
directory node['admin']['storage']['base'] + node['admin']['storage']['user_images'] do
    action :create
    owner node['admin']['user']
    group node['admin']['user']
    recursive true
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
