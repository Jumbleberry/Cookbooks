# Make sure directory exists
# Use the same user defined for the jbx application
directory node['admin']['path'] do
  owner node['jbx']['user']
  group node['jbx']['user']
end

branch = ENV['JB_ADMIN_BRANCH'] || node['admin']['branch']

git node['admin']['path'] do
  if !node['admin']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['admin']['github_key'] + "_wrapper.sh"
  end
  repository node['admin']['git-url']
  revision branch
  user node['jbx']['user']
  action :sync
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['admin']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['admin']['hostname']

template virtualhost do
  source    "nginx/admin.jumbleberry.com.erb"
  variables ({
    "hostname"      => node['admin']['hostname'],
    "path"          => "#{node['admin']['path']}/public",
    "environment"   => node['admin']['environment']
  })
end

#Add application configurations
template "#{node['admin']['path']}/application/configs/application.ini" do
  source  "admin/application.ini.erb"
end

#Add cron configurations
template "#{node['admin']['path']}/cron_scripts/includes/config/settings.php" do
  source  "admin/settings.php.erb"
end

#Nginx service
service 'nginx' do
  action :start
end