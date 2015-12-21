cron "Mesh - Cache Buster" do
  command "/usr/bin/php #{node[:jbx][:mesh][:path]}/crons/cache_buster.php"
  minute '*'
  user 'www-data'
  action :create
end