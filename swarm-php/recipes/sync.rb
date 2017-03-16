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