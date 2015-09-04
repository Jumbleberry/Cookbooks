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
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_orders.php only_initial"
  hour '0-2,7-23'
  minute '20'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Rebill Orders" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_orders.php"
  hour '*'
  minute '0-15,30-59'
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

cron "Processing - Calculate Retentions" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/calculate_retentions.php"
  hour '*'
  user 'www-data'
  action :create
end

cron "Processing - Cap Summary Current Week" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/hitpath_summary_campaign_caps.php current_week"
  minute '*/3'
  user 'www-data'
  action :create
end

cron "Processing - Cap Summary Previous Week" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/hitpath_summary_campaign_caps.php"
  minute '0'
  weekday '1'
  hour '2'
  user 'www-data'
  action :create
end

cron "Processing - Effective CAP Sunday Snapshot" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '5'
  weekday '1'
  hour '0'
  user 'www-data'
  action :create
end

cron "Processing - Effective CAP Monday Rollback" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '0'
  weekday '1'
  hour '16'
  user 'www-data'
  action :create
end