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
  user node['admin']['user']
  action :sync
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
  notifies :reload, "service[nginx]", :delayed
end
