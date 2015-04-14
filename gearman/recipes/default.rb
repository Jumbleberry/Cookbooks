include_recipe "jb_consul"

# Add ppa repository
apt_repository 'gearman-developers' do
  uri           'ppa:gearman-developers/ppa'
  distribution  'precise'
  components    ['main', 'stable']
end

include_recipe "apt"

#Add mysql library used by gearmam to handle persistent queues
package 'libmysqld-dev' do
  action :install
end

#Install gearman package
package 'gearman' do
    action :install
    version node["gearman"]["version"]
end

#Update configuration file
template '/etc/init/gearman-job-server.conf' do
    source 'gearman-job-server.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

execute "sudo killall gearmand || true" do
    user "root"
    ignore_failure true
end

include_recipe "gearman::deploy"

# Consul Integration
consul_path = node["consul"]["config_dir"]
cron_path   = node["consul"]["config_dir"]

# Add the cron helper libraries to the consul config folder
remote_directory "#{cron_path}/GearmanAdmin" do
    source "GearmanAdmin"
    files_mode "0664"
    owner "root"
    group "root"
    mode "0775"
end

# Move the health check file
cookbook_file "gearman_check.php" do
    path "#{cron_path}/gearman_check.php"
    owner "root"
    group "cluster"
    mode "0755"
end

#Creates the service configuration file
template "#{consul_path}/gearman.json" do
    source "gearman_service.json.erb"
    owner "root"
    group "cluster"
    mode "0664"
    variables ({
        "currentip" => node["gearman"]["ip"],
        "consul_path" => consul_path
    })
end

# Reload consul
execute "reload consul configuration" do
    command "consul reload || true"
    ignore_failure true
    user "root"
end