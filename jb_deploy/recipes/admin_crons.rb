# Sync All Hitpath Data
cron "Admin - Sync Hitpath" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_hitpath.php"
  minute '*/3'
  user 'www-data'
  action :create
end

cron "Admin - Sale Projections" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/generate_projections.php"
  minute '2-59/3'
  user 'www-data'
  action :create
end

cron "Admin - Notifications" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/cap_notifications.php"
  minute '4-59/5'
  user 'www-data'
  action :create
end

cron "Admin - Advertiser Prepay" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/advertiser_limits.php"
  minute '0'
  user 'www-data'
  action :create
end

cron "Admin - Pull Phone Data" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_phone.php"
  minute '45'
  user 'www-data'
  action :create
end

cron "Admin - Hitpath Raw Logs" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/raw_log_alerts.php"
  minute '4-59/5'
  user 'www-data'
  action :create
end

cron "Admin - Upload Sales Reports" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/upload_sales_report.php"
  minute '0'
  hour '*/4'
  user 'www-data'
  action :create
end