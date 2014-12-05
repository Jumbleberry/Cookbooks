#System configurations
#Shared memory limits
execute "sysctl-config" do
  command "/sbin/sysctl -p"
  action :nothing
end

template '/etc/sysctl.conf' do
  source 'sysctl.conf.erb'
  user 'root'
  variables ({
    'shmmax' => node['system']['shared_memory']['shmmax'],
    'shmall' => node['system']['shared_memory']['shmall'],
    'shmmni' => node['system']['shared_memory']['shmmni']
  })
  notifies :run, "execute[sysctl-config]", :immediately
end

# Custom repositories
apt_repository 'php5.5-ppa' do
  uri           'ppa:ondrej/php5'
  distribution  'precise'
  components    ['main', 'stable']
end

execute "sudo apt-get update" do
end

#System packages
syspackages = ['git', 'gcc', 'vim', 'libpcre3-dev', 'make', 'curl', 'unzip']
syspackages.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

# Make sure directory exists
directory "/var/www/" do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
end

ssh_known_hosts_entry 'github.com'