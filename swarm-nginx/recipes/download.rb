remote_file '/etc/nginx/nginx' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx?raw=true'
    action :create
    mode '0755'
    notifies :run, 'execute[nginx]', :immediate
end
execute 'nginx' do
    command <<-EOH
        ln -s /etc/nginx/nginx /usr/bin/nginx-new && mv -Tf /usr/bin/nginx-new /usr/bin/nginx
    EOH
    action :nothing
    notifies :enable, 'service[nginx]', :delayed
    notifies :start, 'service[nginx]', :delayed
    notifies :reload, 'service[nginx]', :delayed
end