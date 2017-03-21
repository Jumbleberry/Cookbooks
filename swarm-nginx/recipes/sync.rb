# Sleep for 3 minutes to wait for deployment
execute 'sleep 180'

# Empty out memcached
execute 'clear memcached' do
    command 'echo "flush_all" | nc localhost 11211'
    user 'root'
    action :run
end

# empty out shared memory
["ssi", "php", "ps", "ps/file", "ps/memory"].each do |type|
    directory '/dev/shm/' + type do
        owner 'www-data'
        group 'www-data'
        mode 0664
        action :create
        recursive true
    end
    directory '/dev/shm/' + type do
        owner 'www-data'
        group 'www-data'
        mode 0664
        action :create
        recursive true
    end
end

service "nginx" do 
    provider Chef::Provider::Service::Upstart
    ignore_failure true
    supports :restart=>true, :status=>true, :reload=>true, :start=>true, :stop=>true
    action :reload
end