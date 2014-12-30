#Copy the cron script to the consul configuration folder
cron_path = node["consul"]["config_dir"]
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
