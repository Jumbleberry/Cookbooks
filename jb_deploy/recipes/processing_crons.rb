cron "Processing - Detect CRM Features" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/detect_features.php"
  hour '2-23/6'
  minute '2-59/10'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Campaigns" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_campaigns.php"
  hour '0-2,6,8-23'
  minute '4-59/10'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Current Day Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_current_stats.php"
  hour '0-2,6,8-23'
  minute '6-59/10'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Historical Stats" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_historical_stats.php"
  hour '3,5'
  minute '8-59/10'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Rebill Orders" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_orders.php"
  hour '*'
  minute '1-59/2'
  user 'www-data'
  action :create
end

cron "Processing - Get CRM Current Orders" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_orders.php only_initial"
  hour '0-2,7-23'
  minute '30'
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
  hour '5'
  minute '15'
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
  action :delete
end

cron "Processing - Effective CAP Sunday Snapshot - Incremental" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '*'
  weekday '1'
  hour '7-15'
  user 'www-data'
  action :delete
end

cron "Processing - Effective CAP Monday Rollback" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '0'
  weekday '1'
  hour '16'
  user 'www-data'
  action :delete
end

cron "Processing - Bridge Page Detection & Scraping" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/scrape_bridge_pages.php"
  minute '0'
  hour '4-23/12'
  user 'www-data'
  action :delete
end

cron "Processing - Cap Deltas" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_deltas.php"
  minute '10'
  weekday '1'
  hour '0'
  user 'www-data'
  action :create
end

cron "Processing - Caps Reached" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/get_caps_reached.php"
  minute '*/1'
  user 'www-data'
  action :create
end

cron "Processing - Future Caps" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/future_caps.php"
  minute '*'
  user 'www-data'
  action :create
end

cron "Processing - Cap Sunday Snapshot" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_snapshot.php"
  minute '*'
  hour '0-23'
  weekday '0,5,6'
  user 'www-data'
  action :create
end

cron "Processing - Cap Monday Snapshot" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_snapshot.php"
  minute '*'
  weekday '1'
  hour '1-16'
  user 'www-data'
  action :create
end

cron "Processing - Cap Approval Monday Midnight" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '15'
  hour '0'
  weekday '1'
  user 'www-data'
  action :create
end

cron "Processing - Cap Approval Monday 4pm" do
  command "/usr/bin/php #{node[:jbx][:processing][:path]}/crons/cap_approval.php"
  minute '0'
  hour '16'
  weekday '1'
  user 'www-data'
  action :create
end
