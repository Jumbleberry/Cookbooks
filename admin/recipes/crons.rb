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

# cron "Admin - CRM Data" do
#   command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/crm_stats.php"
#   minute '0'
#   user 'www-data'
#   action :create
# end
# 
# cron "Admin - CRM Data Report" do
#   command "/usr/bin/php #{node[:admin][:path]}/cron_scripts/crm_data_report.php"
#   minute '30'
#   hour '8'
#   weekday '5,0'
#   user 'www-data'
#   action :create
# end

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