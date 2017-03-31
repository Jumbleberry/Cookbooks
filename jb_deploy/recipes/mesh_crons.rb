cron "Mesh - Cache Buster" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/cache_buster.php"
  minute '*'
  user 'www-data'
  action :delete
end

cron "Mesh - Bridge Cache Buster" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/bridge_cache_buster.php"
  minute '*'
  user 'www-data'
  action :create
end

cron "Mesh - Campaign Cache Buster" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/campaign_cache_buster.php"
  minute '*'
  user 'www-data'
  action :create
end

cron "Mesh - Optimizer EPC Reporting" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/epc_reporting.php"
  minute '*/3'
  user 'www-data'
  action :create
end