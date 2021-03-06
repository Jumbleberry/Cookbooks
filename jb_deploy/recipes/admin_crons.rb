# Sync All Hitpath Data
cron "Admin - Sync Hitpath" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_hitpath.php"
  minute '*'
  user 'www-data'
  action :create
end

cron "Admin - Sale Projections" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/generate_projections.php"
  minute '30'
  user 'www-data'
  action :create
end

cron "Admin - Notifications" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/cap_notifications.php"
  minute '*/5'
  user 'www-data'
  action :create
end

cron "Admin - Hitpath Raw Logs" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/raw_log_alerts.php"
  minute '*/5'
  user 'www-data'
  action :create
end

cron "Admin - Advertiser Prepay" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/advertiser_limits.php"
  minute '*/15'
  user 'www-data'
  action :delete
end

cron "Admin - Effective Cap Notification" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/effective_cap_notifications.php"
  minute '5'
  hour '1'
  user 'www-data'
  action :create
end

cron "Admin - Advertiser Terms" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/advertiser_terms.php"
  hour '*'
  minute '0'
  user 'www-data'
  action :create
end

cron "Admin - Pull Phone Data" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_phone.php"
  minute '*/15'
  hour '8-19'
  user 'www-data'
  action :create
end

# Defunct
cron "Admin - Upload Sales Reports" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/upload_sales_report.php"
  minute '0,2'
  hour '*'
  user 'www-data'
  action :delete
end
