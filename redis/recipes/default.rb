#Redis installation
#Turn off huge pages
execute 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' do
  user 'root'
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
directory node['redis']['log'] do
    action :create
    owner 'root'
    group 'root'
end

#Creates configurations directory
directory node['redis']['config'] do
    action :create
    owner 'root'
    group 'root'
end

# Template files
templates = {
  'redis.conf.erb'        => 'redis.conf',
  'sentinel.conf.erb'     => 'sentinel.conf',
  'server-template.erb'   => 'server-template',
  'create_servers.rb.erb' => 'create_servers.rb'
}

# Create config files
templates.each do | origin, dest |
  template node['redis']['config'] + '/' + dest do
    source origin
  end
end

#Creates servers directory
directory node['redis']['config'] + '/servers' do
    action :create
    owner 'root'
    group 'root'
end

#Link to binary files
binaries = ['redis-server', 'redis-sentinel', 'redis-cli']

binaries.each do | file |
    link "/usr/local/bin/#{file}" do
      to "#{path}/src/#{file}"
    end
end

# Create servers
execute "create redis servers" do
  command "ruby " + node['redis']['config'] + "/create_servers.rb" do
    user 'root'
  end
end

#Add init scripts
init_files = {
  'redis_init_script.erb'    => 'redis',
  'sentinel_init_script.erb' => 'redis-sentinel'
}

init_files.each do | origin, dest |
  #Copy init scripts to destination
  init_files.each do | origin, dest |
    template '/etc/init.d/' + dest do
      source origin
      owner 'root'
      group 'root'
      mode 755
    end
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