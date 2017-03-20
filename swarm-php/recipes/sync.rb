# Sleep for 3 minutes to wait for deployment
execute 'sleep 180'

service 'php7.0-fpm' do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 14.04
      provider Chef::Provider::Service::Upstart
    end
  end
  supports :restart=>true, :status=>true, :reload=>true, :start=>true, :stop=>true
  action :reload
end

execute 'warm-cache' do
    command '/usr/bin/php /html/admin/warm_cache.php'
    user 'www-data'
    action :run
end

cron 'warm_cache.php' do
  action :create
  minute '*/5'
  user 'www-data'
  command '/usr/bin/php /html/admin/warm_cache.php'
end