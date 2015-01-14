include_recipe "jb_consul"
include_recipe "redisio"
include_recipe "redisio::sentinel"

redis_path = '/etc/redis'
consul_path = node["consul"]["config_dir"]

# Add redis to the cluster group
group "cluster" do
  action :create
  members ["redis", "root"]
  append true
end

# Get every redis server for the current instance
servers = node['redisio']['servers'];
sentinels = node['redisio']['sentinels'];

# Copy the cron scrip to the redis config path
template "#{redis_path}/redis_cron.php" do
    source "redis_cron.php.erb"
    owner "root"
    group "root"
    variables ({
        "redis_path" => redis_path
    })
end

# Get the ip of the interface on the consul attributes
local_ip = node["network"]["interfaces"][node['consul']['bind_interface']]["addresses"].detect{|k,v| v[:family] == "inet"}.first

unless servers.empty?
    servers.each do |server|
        #Run consul cron job
        cron "Redis cron #{server.port}" do
            command "/usr/bin/php #{redis_path}/redis_cron.php #{local_ip} #{server.port}"
            user "root"
            action :create
        end

        #Creates the service configuration file
        template "#{consul_path}/redis#{server.port}.json" do
            source "redis_service.json.erb"
            owner "root"
            group "cluster"
            mode "0664"
            variables ({
                "port" => server.port,
                "currentip" => local_ip,
                "consul_path" => consul_path
            })
        end

        #Create log file with the right permissions
        if(server[:logfile])
            file server.logfile do
                owner "redis"
                group "redis"
                mode  "0644"
            end
        end
    end
end

sentinels.each do |sentinel|
    if(sentinel[:logfile])
        #Create log file with the right permissions
        file sentinel.logfile do
            owner "redis"
            group "redis"
            mode  "0644"
        end
    end
end

if servers.empty? && !sentinels.empty?
    #Run consul cron job
    cron "Redis Sentinel cron" do
        command "/usr/bin/php #{redis_path}/redis_cron.php"
        user "root"
        action :create
    end
end

#Creates the service configuration file
template "#{consul_path}/sentinel_reconf_script.php" do
    source "sentinel_reconf_script.php.erb"
    owner "root"
    group "root"
    mode "0755"
    variables ({
        "currentip" => local_ip
    })
end

#Creates the service configuration file
template "#{consul_path}/redis_check.php" do
    source "redis_check.php.erb"
    owner "root"
    group "root"
    mode "0755"
end

execute "reload consul configuration" do
    command "consul reload"
    ignore_failure true
    user "root"
end