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


package 'gperf' do
  action :install
end

# Get all gearman build dependencies
execute "build gearman" do
    command "DEBIAN_FRONTEND=noninteractive &&
                apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' build-dep gearman-job-server -y &&
                apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade gearman-job-server -y  &&
                apt-get install gperf &&
                cd /tmp &&
                wget https://launchpad.net/gearmand/1.2/#{node['gearman']['source']['version']}/+download/gearmand-#{node['gearman']['source']['version']}.tar.gz && 
                tar -xvzf gearmand-#{node['gearman']['source']['version']}.tar.gz &&
                cd gearmand-#{node['gearman']['source']['version']} && 
                ./configure && make && make install;
                service gearman-job-server stop;
                pkill -9 -u `id -u gearman`;
                cp gearmand/gearmand /usr/sbin/ && cp gearmand/gearmand /usr/local/sbin/
                ";
    user "root"
    not_if "/usr/sbin/gearmand -V | grep #{node['gearman']['source']['version']}"
end

#Update configuration file
template '/etc/init/gearman-job-server.conf' do
    source 'gearman-job-server.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

execute "pkill -9 -u `id -u gearman`" do
    user "root"
    ignore_failure true
end


include_recipe "ulimit2"
include_recipe "jb_deploy::gearman"

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