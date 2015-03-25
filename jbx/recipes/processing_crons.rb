cron "Processing - Detect CRM Features" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/detect_features.php"
  hour '4'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Campaigns" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_campaigns.php"
  minute '45'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Daily Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_daily_stats.php"
  minute '5'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Weekly Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_weekly_stats.php"
  hour '2,4,6'
  user 'www-data'
  action :create
end