# Sync All Hitpath Data
cron "Sync Hitpath" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_hitpath.php"
  minute '*/3'
  action :create
end

cron "Sale Projections" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/generate_projections.php"
  minute '2-59/3'
  action :create
end

cron "Notifications" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/cap_notifications.php"
  minute '4-59/5'
  action :create
end

cron "CRM Data" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/crm_stats.php"
  minute '0'
  action :create
end

cron "CRM Data Report" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/crm_data_report.php"
  minute '30'
  hour '8'
  day '5,0'
  action :create
end

cron "Advertiser Prepay" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/advertiser_limits.php"
  minute '0'
  action :create
end

cron "Pull Phone Data" do
  command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/sync_phone.php"
  minute '45'
  action :create
end