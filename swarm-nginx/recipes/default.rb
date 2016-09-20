include_recipe "apt"
include_recipe "ulimit"

user 'www-data' do
  comment 'web user'
  home '/html'
  shell '/bin/bash'
  action :create
  ignore_failure true
end
group 'www-data' do
  action :create
  members 'www-data'
  append true
  ignore_failure true
end
["ssi", "php", "ps/file", "ps/memory"].each do |type|
    directory '/dev/shm/' + type do
        owner 'www-data'
        group 'www-data'
        mode 0644
        action :create
        recursive true
    end
end
["/etc/nginx", "/var/log/nginx", "/usr/local/nginx/html"].each do |dir|
    directory dir do
        owner 'www-data'
        group 'www-data'
        mode 0644
        action :create
        recursive true
    end
end

# Configure memcached
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end
apt_package 'memcached' do
    action :install
end
service "memcached" do
    action :nothing
end
template 'memcached.conf' do
  source 'memcached.conf.erb'
  path '/etc/memcached.conf'
  variables({
    'cache_size' => (node['memory']['total'][0..-3].to_i / 12 ),
  })
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[memcached]', :immediate
end

# Either build from source, or download pre-compiled
include_recipe 'swarm-nginx::download'

cookbook_file 'upstart.conf' do
  source 'upstart.conf'
  path '/etc/init/nginx.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :run, 'execute[upstart]', :immediate
end
execute 'upstart' do
    command <<-EOH
        initctl reload-configuration
    EOH
    action :nothing
    notifies :enable, 'service[nginx]', :immediate
    notifies :start, 'service[nginx]', :delayed
    notifies :reload, 'service[nginx]', :delayed
end
["mime.types", "dhparam.pem", "ticket.key"].each do | file |
    cookbook_file file do
      source file
      path '/etc/nginx/' + file
      owner 'root'
      group 'root'
      mode '0644'
      action :create
      notifies :enable, 'service[nginx]', :delayed
      notifies :start, 'service[nginx]', :delayed
      notifies :reload, 'service[nginx]', :delayed
    end
end
template 'fastcgi.conf' do
  path '/etc/nginx/fastcgi.conf'
  source 'fastcgi.conf.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  action :create
  notifies :enable, 'service[nginx]', :delayed
  notifies :start, 'service[nginx]', :delayed
  notifies :reload, 'service[nginx]', :delayed
end
template 'nginx.conf' do
  path '/etc/nginx/nginx.conf'
  source 'nginx.conf.erb'
  variables({
    'cache_size' => (node['memory']['total'][0..-3].to_i / 12 ),
  })
  owner 'www-data'
  group 'www-data'
  mode '0644'
  action :create
  notifies :enable, 'service[nginx]', :delayed
  notifies :start, 'service[nginx]', :delayed
  notifies :reload, 'service[nginx]', :delayed
end
service "nginx" do 
    provider Chef::Provider::Service::Upstart
    ignore_failure true
    action :nothing
end

cron 'nginx' do
  action :create
  minute '*'
  user 'root'
  command 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; /usr/sbin/service nginx reload'
end