include_recipe "timezone-ii"

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

execute "sudo apt-get update" do
end

#System packages
syspackages = ['git', 'gcc', 'vim', 'libpcre3-dev', 'make', 'curl', 'unzip']
syspackages.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

# we're running on a vagrant machine - make it easier to manage /var/www/
if File.directory?('/home/vagrant')
    
    directory '/var/www' do
      recursive true
      action :delete
      not_if { File.symlink?('/var/www') }
    end
    
    link '/var/www' do
      to '/home/vagrant/www/'
      owner node['user']
      group node['user']
      action :create
      not_if { File.symlink?('/var/www') }
    end

# Not on vagrant - use a normal directory
else 
    
    link '/var/www' do
      to '/home/vagrant/www/'
      action :delete
      only_if { File.symlink?('/var/www') }
    end
    
    # Make sure directory exists
    directory "/var/www/" do
      owner node["user"]
      group node["user"]
      recursive true
      action :create
    end
    
end

ssh_known_hosts_entry 'github.com'
include_recipe "php"