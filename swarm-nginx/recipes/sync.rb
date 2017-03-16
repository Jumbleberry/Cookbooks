# Sleep for 3 minutes to wait for deployment
execute 'sleep 180'

service "nginx" do 
    provider Chef::Provider::Service::Upstart
    ignore_failure true
    supports :restart=>true, :status=>true, :reload=>true, :start=>true, :stop=>true
    action :reload
end