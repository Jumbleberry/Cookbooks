cron "Processing - Detect CRM Features" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/detect_features.php"
  hour '4'
  minute '0'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Campaigns" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_campaigns.php"
  hour '2-23/4'
  minute '45'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Current Day Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_current_stats.php"
  hour '0-2,4,6,8-23'
  minute '15'
  user 'www-data'
  action :delete
end

cron "Processing - Get CRM Historical Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_historical_stats.php"
  hour '3,5,7'
  minute '15'
  user 'www-data'
  action :create
end

cron "Processing - Datadog Stats Reporting" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/datadog_reporting.php"
  minute '*'
  user 'www-data'
  action :create
end