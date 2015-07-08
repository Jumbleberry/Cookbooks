include_recipe "timezone-ii"

# IF not amazon - update hosts file
if ( !node.attribute?('ec2') || !node[:ec2].attribute?('instance_id') || !/(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]))

    template '/etc/hosts' do
      source "vagrant_hosts.erb"
      mode "0644"
    end
else
    
    include_recipe "opsworks_stack_state_sync"

end

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
syspackages = ['git', 'gcc', 'vim', 'libpcre3-dev', 'make', 'curl', 'unzip', 'uuid']
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

    # Makes sure that the www directory exists
    directory '/vagrant/www' do
        owner node['user']
        group node['user']
        action :create
    end
    
    link '/var/www' do
      to '/vagrant/www/'
      owner node['user']
      group node['user']
      action :create
      not_if { File.symlink?('/var/www') }
    end

# Not on vagrant - use a normal directory
else 
    
    link '/var/www' do
      to '/vagrant/www/'
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