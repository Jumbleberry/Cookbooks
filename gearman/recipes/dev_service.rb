consul_path = node["consul"]["config_dir"]

#Creates the service configuration file
template "#{consul_path}/gearman.json" do
    source "gearman_dev.json.erb"
    owner "root"
    group "cluster"
    mode "0664"
end

# Reload consul
execute "reload consul configuration" do
    command "consul reload || true"
    ignore_failure true
    user "root"
end
