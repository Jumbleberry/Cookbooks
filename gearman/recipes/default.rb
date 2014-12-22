# Add ppa repository
apt_repository 'gearman-developers' do
  uri           'ppa:gearman-developers/ppa'
  distribution  'precise'
  components    ['main', 'stable']
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

#Update configuration file
template '/etc/init/gearman-job-server.conf' do
    source 'gearman-job-server.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

#Update configuration file
template '/etc/default/gearman-job-server' do
    source 'gearman-job-server.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

#Register service
service 'gearman-job-server' do
    action :restart
end
