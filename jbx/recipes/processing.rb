include_recipe "jbx::core"
include_recipe "gearman"

# Set the branch to checkout
branch = ENV['JBX_PROCESSING_BRANCH'] || node['jbx']['processing']['branch']

git node['jbx']['processing']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/processing_wrapper.sh"
  repository node['jbx']['processing']['git-url']
  revision branch
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['processing']['path']}"
  user "root"
  action :run
end

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
service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end

# Un-symlink our config script to prevent install file from overwriting our good version
link "/etc/gearman-manager/config.ini" do
    to "#{node['jbx']['processing']['path']}/config/config.ini"
    action :delete
    only_if { File.symlink?("/etc/gearman-manager/config.ini") }
end

# Install gearman manager
execute "echo 1 | /bin/bash install.sh" do
    cwd "#{node['jbx']['core']['path']}/application/vendor/brianlmoon/gearmanmanager/install"
    user "root"
end

# We need to chmod gearman manager...
file "/usr/local/bin/gearman-manager" do
    action :touch
    mode "0755"
    owner "root"
    group "root"
end

# Delete the config script if it isnt a symlink to processing
file "/etc/gearman-manager/config.ini" do
    action :delete
    not_if { File.symlink?("/etc/gearman-manager/config.ini") }
end

# Symlink our config script
link "/etc/gearman-manager/config.ini" do
    to "#{node['jbx']['processing']['path']}/config/config.ini"
    action :create
    owner "www-data"
    group "www-data"
end

# Start the service
service "gearman-manager" do
    supports :status => true, :restart => true, :start => true, :stop => true
    action :restart
end
