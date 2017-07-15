consul_path = node["consul"]["config_dir"]

# -------------------
# Redis configuration
# -------------------
package "redis-tools" do
    action :install
    # Ignore configuration changes
    options '--force-yes'
end

# Delete the redis service files
execute "sudo rm -rf #{consul_path}/elasticache*.json" do
    user 'root'
end

local_ip = node["network"]["interfaces"][node[:network_interface]]["addresses"].detect{|k,v| v[:family] == "inet"}.first
servers = node['redisio']['servers'];

if servers.kind_of?(Array) && !servers.empty?
    servers.each do |server|
        
        #Creates the service configuration file
        template "#{consul_path}/elasticache#{server.port}.json" do
            source "redis_service.json.erb"
            owner "root"
            group "cluster"
            mode "0664"
            variables ({
                "name" => "elasticache",
                "port" => server.port,
                # Doesn't play well when address is 0.0.0.0, use real ip instead
                "address" => server.server == "0.0.0.0"? nil: server.server,
                "currentip" => server.server == "0.0.0.0"? local_ip: server.server,
                "consul_path" => consul_path,
                "tag" => :slave + '","' + :master
            })
        end
    end
end

# Service check
template "#{consul_path}/redis_check.php" do
    source "redis_check.php.erb"
    owner "root"
    group "root"
    mode "0755"
end

execute "reload consul configuration" do
    command "consul reload || true"
    ignore_failure true
    user "root"
end