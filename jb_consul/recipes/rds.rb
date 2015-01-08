consul_path = node["consul"]["config_dir"]

node['rds'].each do | name, connections |
  connections.each do | role, fields |
    #Creates the service configuration file
    template "#{consul_path}/#{name}_#{role}.json" do
        source "rds.json.erb"
        owner "root"
        group "root"
        mode "0755"
        variables ({
            "role" => role,
            "host" => fields.host,
            "port" => fields.port || 3306,
            "name" => name
        })
    end
  end
end

execute "consul reload || true"