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

# -------------------
# Redis configuration
# -------------------

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
local_ip = node["network"]["interfaces"][node[:network_interface]]["addresses"].detect{|k,v| v[:family] == "inet"}.first

if servers.kind_of?(Array) && !servers.empty?
    servers.each do |server|
        
        #Creates the service configuration file
        template "#{consul_path}/redis#{server.port}.json" do
            source "redis_service.json.erb"
            owner "root"
            group "cluster"
            mode "0664"
            variables ({
                "port" => server.port,
                "currentip" => local_ip,
                "consul_path" => consul_path,
                "tag" => :slave
            })
        end
        
        #Run consul cron job
        cron "Redis cron #{server.port}" do
            command "/usr/bin/php #{redis_path}/redis_cron.php #{local_ip} #{server.port}"
            user "root"
            action :create
        end
        
        # Run the cron
        execute "/usr/bin/php #{redis_path}/redis_cron.php #{local_ip} #{server.port} &" do
            user "root"
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
else
    # Delete the redis cron file
    execute "sudo rm -rf #{consul_path}/redis*.json" do
        user 'root'
    end
end

# -----------------------
# Sentinels configuration
# -----------------------

# Copy the cron scrip to the redis config path
template "#{redis_path}/sentinel_cron.php" do
    source "sentinel_cron.php.erb"
    owner "root"
    group "root"
    variables ({
        "redis_path" => redis_path
    })
end

if sentinels.kind_of?(Array) && !sentinels.empty?
    sentinels.each do |sentinel|        
        #Run consul cron job
        cron "Redis cron #{sentinel.name}" do
            command "/usr/bin/php #{redis_path}/sentinel_cron.php #{local_ip} #{sentinel.port}"
            user "root"
            action :create
        end

        #Creates the service configuration file
        template "#{consul_path}/sentinel#{sentinel.name}.json" do
            source "sentinel_service.json.erb"
            owner "root"
            group "cluster"
            mode "0664"
            variables ({
                "sentinel_name" => sentinel.name,
                "port" => sentinel.port
            })
        end

        if(sentinel[:logfile])
            #Create log file with the right permissions
            file sentinel.logfile do
                owner "redis"
                group "redis"
                mode  "0644"
            end
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
else
    # Delete the sentinel consul service
    execute "sudo rm -rf #{consul_path}/sentinel*.json" do
        user 'root'
    end
end

execute "reload consul configuration" do
    command "consul reload || true"
    ignore_failure true
    user "root"
end