cron_path = node["consul"]["config_dir"]

# Copy the mocked_stack script for non-production environments
ip = node[:network][:interfaces][node[:consul][:bind_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
template "#{cron_path}/mocked_stack.json" do
    source "mocked_stack.json.erb"
    owner "root"
    group "root"
    variables({
        :ip          => ip,
        :environment => node['environment']
    })
end

#Copy the cron script to the consul configuration folder
template "#{cron_path}/consul_cron.php" do
    source "consul_cron.php.erb"
    owner "root"
    group "root"
end

#Run consul cron job
cron "Consul cron" do
  command "/usr/bin/php #{cron_path}/consul_cron.php"
  user "root"
  action :create
end
