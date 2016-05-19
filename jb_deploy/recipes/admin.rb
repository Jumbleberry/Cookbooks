include_recipe "github-auth"

# Make sure directory exists
# Use the same user defined for the admin application
directory node['admin']['path'] do
  owner node['admin']['user']
  group node['admin']['user']
end

branch = ENV['JB_ADMIN_BRANCH'] || node['admin']['branch']

git node['admin']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/admin_wrapper.sh"
  repository node['admin']['git-url']
  revision branch
  user 'root'
  action :sync
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
    cwd "#{node['admin']['path']}"
    user "root"
end

execute "chown-data-www" do
  command "chown -R #{node['admin']['user']}:#{node['admin']['user']} #{node['admin']['path']}"
  user "root"
  action :run
end

if node['environment'] == 'development'
    jbx_api = node['admin']['api'].sub "https://", ""
else
    jbx_api = node['admin']['api']
end

#Add application configurations
template "#{node['admin']['path']}/application/configs/application.ini" do
  source  "admin/application.ini.erb"
  variables ({
      "jbx_api"   => jbx_api
  })
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