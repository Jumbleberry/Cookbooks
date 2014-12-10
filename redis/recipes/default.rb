#Redis installation
#Turn off huge pages
execute 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' do
  user 'root'
end

#Clone the specified version from the repository
path  = node['redis']['path']

git path do
    repository node['redis']['git_url']
    reference node['redis']['git_ref']
    action :sync
end

# get make
apt_package 'make' do
  action :install
end

#Installation
execute 'redis build' do
    cwd path
    user 'root'
    command %{make}
end

#Creates log directory
directory '/var/log/redis' do
    action :create
    owner 'root'
    group 'root'
end

#Creates configurations directory
directory '/etc/redis' do
    action :create
    owner 'root'
    group 'root'
end

#Configurations files
template '/etc/redis/redis.conf' do
    source 'redis.conf.erb'
end

template '/etc/redis/sentinel.conf' do
    source 'sentinel.conf.erb'
end

#Link to binary files
binaries = ['redis-server', 'redis-sentinel', 'redis-cli']

binaries.each do | file |
    link "/usr/local/bin/#{file}" do
      to "#{path}/src/#{file}"
    end
end

# Copy server template
cookbook_file '/etc/redis/server-template' do
  source 'server-template'
  owner 'root'
  group 'root'
end

# Copy server create file
template '/etc/redis/create_servers.rb' do
  source 'create_servers.rb.erb'
end

#Creates servers directory
directory '/etc/redis/servers' do
    action :create
    owner 'root'
    group 'root'
end

# Create servers
execute "create redis servers" do
  command "ruby /etc/redis/create_servers.rb" do
    user 'root'
  end
end

#Allow overcomit_memory
ruby_block "adds to sysctl" do
    block do
        sysctl = Chef::Util::FileEdit.new('/etc/sysctl.conf')
        sysctl.insert_line_if_no_match('/vm.overcommit_memory/', 'vm.overcommit_memory = 1')
        sysctl.write_file
    end
    not_if "grep -q 'vm.overcommit_memory' /etc/sysctl.conf"
end
execute 'sysctl vm.overcommit_memory=1' do
  user 'root'
end

#Add init scripts
init_files = {
    'redis_init_script' => 'redis',
    'sentinel_init_script' => 'redis-sentinel'
}

init_files.each do | origin, dest |
    #Copy init scripts to destination
    cookbook_file "/etc/init.d/#{dest}" do
        source origin
        owner 'root'
        group 'root'
        mode 0755
    end

    #Update init.d with new scripts
    execute "update init.d for #{dest}" do
        command "sudo update-rc.d #{dest} defaults"
    end

    #Register and start new service
    service dest do
      action :start
    end
end