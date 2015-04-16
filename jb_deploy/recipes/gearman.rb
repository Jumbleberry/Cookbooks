# Force Kill old gearman-manager processes and restart the job server
execute "gearman-restart" do
    command "pkill -9 -u `id -u gearman` && sudo service gearman-job-server restart"
    user "root"
    action :nothing
end

#Update configuration file
server = template '/etc/default/gearman-job-server' do
    source 'gearman-job-server.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[gearman-restart]', :immediately
end