include_recipe "web-server"
include_recipe "apt"

apt_repository 'gearman-ppa' do
  uri           'ppa:ondrej/pkg-gearman'
  distribution  node['lsb']['codename']
  components    ['main']
end

# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update --fix-missing"
    user 'root'
end

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
                apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install libboost-all-dev libevent-dev uuid-dev -y  &&
                apt-get install gperf -y &&
                cd /tmp &&
                wget  -O gearmand-#{node['gearman']['source']['version']}.tar.gz https://github.com/gearman/gearmand/releases/download/#{node['gearman']['source']['version']}/gearmand-#{node['gearman']['source']['version']}.tar.gz && 
                tar -xvzf gearmand-#{node['gearman']['source']['version']}.tar.gz &&
                cd gearmand-#{node['gearman']['source']['version']} && 
                ./configure --with-mysql=yes && make && make install;
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

if node['lsb']['release'].to_f > 16
    template '/etc/systemd/system/gearman-job-server.service' do
      source 'gearman-job-server.service.erb'
      mode 0644
      notifies :restart, 'service[gearman-job-server]', :delayed
    end
end

service 'gearman-job-server' do
    case node['platform']
    when 'ubuntu'
      if node['lsb']['release'].to_f > 16
        provider provider Chef::Provider::Service::Systemd
      elsif node['lsb']['codename'] == 'trusty'
        provider Chef::Provider::Service::Upstart
      end
    end
    supports status: true, restart: true, reload: true, start: true
    action [:enable]
end

execute "pkill -9 -u `id -u gearman`" do
    user "root"
    ignore_failure true
end

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

# Create cluster group
group "cluster" do
  action :create
  members ["root"]
  append true
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
