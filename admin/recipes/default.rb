# Make sure directory exists
directory node['jbx']['admin']['path'] do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
end

git node['jbx']['admin']['path'] do
  if !node['jbx']['admin']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['admin']['github_key'] + "_wrapper.sh"
  end
  repository node['jbx']['admin']['git-url']
  revision branch
  user node['jbx']['user']
  action :sync
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['admin']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['admin']['hostname']

template virtualhost do
  source    "nginx/admin.jumbleberry.com.erb"
  variables ({
    "hostname"  => node['jbx']['admin']['hostname'],
    "path"      => "#{node['jbx']['admin']['path']}/public",
    "app-env"   => node['jbx']['admin']['app-env']
  })
end

link virtualhost_link do
  to virtualhost
  notifies :restart, "service[nginx]", :delayed
end
