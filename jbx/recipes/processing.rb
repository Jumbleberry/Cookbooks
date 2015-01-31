include_recipe "jbx::core"
include_recipe "gearman"
include_recipe "gearman::manager"

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

template "#{node['jbx']['processing']['path']}/config/config.json" do
    source "processing/config.json.erb"
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end
