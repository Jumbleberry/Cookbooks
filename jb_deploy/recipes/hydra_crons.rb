cron "Hydra - Redirect Campaigns" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/redirects_for_capped_campaigns.php"
  minute '*'
  user 'www-data'
  action :create
end