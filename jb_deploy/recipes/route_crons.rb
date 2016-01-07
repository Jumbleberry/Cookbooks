# Sync All Hitpath Data
cron "Route - Sync Sales to Redis" do
  command "/usr/bin/php #{node['jbx']['route']['path']}/crons/sales.php"
  minute '*'
  user 'www-data'
  action :delete
end

cron "Route - Sync Redirects to Redis" do
  command "/usr/bin/php #{node['jbx']['route']['path']}/crons/sync.php"
  minute '*/5'
  user 'www-data'
  action :delete
end