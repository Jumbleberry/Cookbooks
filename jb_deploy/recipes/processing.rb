include_recipe "jb_deploy::core"
include_recipe "jb_deploy::gearman"
include_recipe "github-auth"

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

# Force Kill old gearman processes
execute "kill gearman-manager" do
    command "pkill -9 -u `id -u gearman`"
    user "root"
    action :run
end


# Start the service
service "gearman-manager" do
    supports :status => true, :restart => true, :start => true, :stop => true
    action :restart
end