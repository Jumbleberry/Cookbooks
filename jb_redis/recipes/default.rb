redis_path = '/etc/redis'
consul_path = node["consul"]["config_dir"]

# Get every redis server for the current instance
servers = node['redisio']['servers'];

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
        group "root"
        variables ({
            "port" => server.port
        })
    end
end
