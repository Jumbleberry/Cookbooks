include_recipe "jb_consul"
include_recipe "redisio"

redis_path = '/etc/redis'
consul_path = node["consul"]["config_dir"]

user 'redis' do
  comment 'redis user'
  home '/html'
  shell '/bin/bash'
  action :create
  ignore_failure true
end
# Add redis to the cluster group
group "cluster" do
  action :create
  members ["redis", "root"]
  append true
end

# Get every redis server for the current instance
servers = node['redisio']['servers'];

# -------------------
# Redis configuration
# -------------------

# Get the ip of the interface on the consul attributes
local_ip = node["network"]["interfaces"][node[:network_interface]]["addresses"].detect{|k,v| v[:family] == "inet"}.first

# Delete the redis service files
execute "sudo rm -rf #{consul_path}/redis*.json" do
    user 'root'
end

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
                "tag" => :master
            })
        end
        
        
        #Run consul cron job
        cron "Redis cron #{server.port}" do
            command "/usr/bin/php #{redis_path}/redis_cron.php #{local_ip} #{server.port}"
            user "root"
            action :delete
        end

        #Create log file with the right permissions
        if(server[:logfile])
            file server.logfile do
                owner "redis"
                group "redis"
                mode  "0644"
            end
        end
        
        service "redis#{server.port}" do
            action :start
        end

        # Create startup process
        execute "update-rc.d redis#{server.port} defaults" do
            user "root"
        end
    end
end

# -----------------------
# Sentinels configuration
# -----------------------


#Creates the service configuration file
template "#{consul_path}/redis_check.php" do
    source "redis_check.php.erb"
    owner "root"
    group "root"
    mode "0755"
end

# Delete the sentinel consul service
execute "sudo rm -rf #{consul_path}/sentinel*.json" do
    user 'root'
end

service "consul" do
  action :start
end

execute "reload consul configuration" do
    command "consul reload || true"
    ignore_failure true
    user "root"
end
