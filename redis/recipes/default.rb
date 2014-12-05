#Redis installation
#Clone the specified version from the repository
path  = node['redis']['path']

git path do
    repository node['redis']['git_url']
    reference node['redis']['git_ref']
    action :sync
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