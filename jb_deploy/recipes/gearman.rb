#Update configuration file
server = template '/etc/default/gearman-job-server' do
    source 'gearman-job-server.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

execute "gearman-restart" do
    command "sudo service gearman-job-server restart"
    user "root"
    action :run
    only_if { server.updated_by_last_action? }
end