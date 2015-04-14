#Update configuration file
template '/etc/default/gearman-job-server' do
    source 'gearman-job-server.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[gearman-restart]', :immediately
end

execute "gearman-restart" do
    command "sudo service gearman-job-server restart"
    user "root"
    action :nothing
end