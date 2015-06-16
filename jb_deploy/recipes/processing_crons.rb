cron "Processing - Detect CRM Features" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/detect_features.php"
  hour '4'
  minute '20'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Campaigns" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_campaigns.php"
  hour '2-23/4'
  minute '50'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Current Day Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_current_stats.php"
  hour '0-2,6,8-23'
  minute '20'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Historical Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_historical_stats.php"
  hour '3,5'
  minute '20'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Current Orders" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_current_orders.php"
  hour '0-2,7-23'
  minute '5-59/10'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Historical Orders" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_historical_orders.php"
  hour '4'
  minute '20'
  user 'www-data'
  action :create
end

cron "Processing - Get Unmapped Campaigns" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_unmapped_campaigns.php"
  minute '*/5'
  user 'www-data'
  action :create
end

cron "Processing - Datadog Stats Reporting" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/datadog_reporting.php"
  minute '*'
  user 'www-data'
  action :create
end