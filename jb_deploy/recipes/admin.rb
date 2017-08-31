include_recipe "github-auth"

#Register Php service
service 'php7.1-fpm' do
  case node['platform']
  when 'ubuntu'
    if node['lsb']['release'].to_f > 16
        provider Chef::Provider::Service::Systemd
    elsif node['lsb']['codename'] == 'trusty'
      provider Chef::Provider::Service::Upstart
    end
  end
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

# Make sure directory exists
# Use the same user defined for the admin application
directory node['admin']['path'] do
  owner node['admin']['user']
  group node['admin']['user']
end

branch = ENV['JB_ADMIN_BRANCH'] || node['admin']['branch']

{ :checkout => true, :sync => node[:user] != 'vagrant' }.each do |action, should|
    git node['admin']['path'] do
      ssh_wrapper node['github-auth']['wrapper_path'] + "/admin_wrapper.sh"
      repository node['admin']['git-url']
      revision branch
      user 'root'
      action action
      notifies :reload, "service[php7.1-fpm]", :delayed
      only_if { should }
    end
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
    jbx_api = node['admin']['api'].sub "https://", "http://"
else
    jbx_api = node['admin']['api']
end

#Add application configurations
template "#{node['admin']['path']}/application/configs/application.ini" do
  source  "admin/application.ini.erb"
  variables ({
      "jbx_api"   => jbx_api
  })
  not_if { node[:user] == 'vagrant' && ::File.exist?("#{node['admin']['path']}/application/configs/application.ini") }
end

#Add cron configurations
template "#{node['admin']['path']}/cron_scripts/includes/config/settings.php" do
  source  "admin/settings.php.erb"
  not_if { node[:user] == 'vagrant' && ::File.exist?("#{node['admin']['path']}/cron_scripts/includes/config/settings.php") }
end

#Creates bucket directory
directory node['admin']['storage']['base'] + node['admin']['storage']['user_images'] do
    action :create
    owner node['admin']['user']
    group node['admin']['user']
    recursive true
end
