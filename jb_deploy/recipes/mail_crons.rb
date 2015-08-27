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