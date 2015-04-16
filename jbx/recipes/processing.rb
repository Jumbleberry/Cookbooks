include_recipe "jbx::core"
include_recipe "gearman"
include_recipe "gearman::ui"

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

include_recipe "jb_deploy::processing"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['processing']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['processing']['hostname']

template virtualhost do
  source    "nginx/processing.erb"
  variables ({
    "hostname"  => node['jbx']['processing']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public",
    "resources_path" => "#{node['jbx']['core']['path']}/application/modules/processing/resources"
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