cron "Mail - Credential Status Notice" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/credential_status.php"
  hour '9'
  minute '0'
  weekday 2
  user 'www-data'
  action :create
end

cron "Mail - Credential Campaigns Notice" do
  command "/usr/bin/php #{node[:jbx][:mail][:path]}/crons/credential_campaigns.php"
  hour '9'
  minute '0'
  weekday 2
  user 'www-data'
  action :create
end