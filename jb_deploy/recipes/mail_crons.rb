cron "Mail - Credential Status Notice" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/credential_status.php"
  hour '9'
  minute '0'
  weekday 3
  user 'www-data'
  action :create
end

cron "Mail - Credential Campaigns Notice" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/credential_campaigns.php"
  hour '9'
  minute '0'
  weekday 3
  user 'www-data'
  action :create
end

cron "Mail - CAP Approvals Notices" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/cap_approval.php"
  hour '8,16'
  minute '10'
  weekday 1
  user 'www-data'
  action :create
end

cron "Mail - Affiliate Cap Notices" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/cap_notices.php"
  minute '*/1'
  user 'www-data'
  action :delete
end

cron "Mail - Cap Exception Report" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/cap_exception_report.php"
  minute '20'
  hour '0'
  weekday '1'
  user 'www-data'
  action :create
end