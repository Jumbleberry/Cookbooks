# Install nginx
service 'nginx' do
    supports status: true, restart: true, reload: true, enable: true
    action :nothing
end
apt_repository 'nginx-stable' do
  uri           'ppa:nginx/stable'
  distribution  node['lsb']['codename']
  components    ['main']
end
execute 'install-nginx' do
  command <<-EOH
    sudo apt-get update
    sudo RUNLEVEL=1 apt-get install nginx -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-install-recommends
    systemctl enable nginx.service
    EOH
  action :run
  only_if { !File.exists?('/usr/sbin/nginx') }
end

# Install openresty
service 'openresty' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end
execute 'install-openresty' do
  command <<-EOH
    wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
    sudo apt-get update
    sudo RUNLEVEL=1 apt-get install openresty=1.11.2.5* -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-install-recommends
    systemctl disable openresty.service
    EOH
  action :run
  notifies :stop, 'service[openresty]', :immediately
  only_if { !File.exists?('/usr/bin/openresty') }
end
remote_file '/etc/nginx/openresty' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/openresty?raw=true'
    action :create
    mode '0755'
    notifies :run, 'execute[copy-openresty]', :immediate
end
execute 'copy-openresty' do
    command <<-EOH
        ln -s /etc/nginx/openresty /usr/bin/openresty-new && mv -Tf /usr/bin/openresty-new /usr/sbin/nginx
    EOH
    action :nothing
    notifies :enable, 'service[nginx]', :delayed
    notifies :restart, 'service[nginx]', :delayed
end

# Install lua-rocks
execute 'install-luarocks' do
    command <<-EOH
        wget http://luarocks.github.io/luarocks/releases/luarocks-2.4.3.tar.gz \
             && tar -xvf luarocks-2.4.3.tar.gz \
             && cd luarocks-* \
             && ./configure --prefix=/usr/local/openresty/luajit \
                    --with-lua=/usr/local/openresty/luajit/ \
                    --lua-suffix=jit \
                    --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
             && make build \
             && make install
    EOH
    action :run
    cwd '/tmp'
    only_if { !File.exists?('/usr/local/openresty/luajit/bin/luarocks') }
end

#Removes the default virtual host if exists
['default.dpkg-dist'].each do | file |
    if (File.file?('/etc/nginx/sites-enabled/' + file))
        link '/etc/nginx/sites-enabled/' + file do
          action :delete
        end
    end
    if (File.file?('/etc/nginx/sites-available/' + file))
        file '/etc/nginx/sites-available/' + file do
          action :delete
        end
    end
end

template '/etc/nginx/nginx.conf' do
  source    "nginx.conf.erb"
  variables ({
    "worker_processes" => node['nginx']['worker_processes'],
    "worker_connections" => node['nginx']['worker_connections']
  })
  notifies :reload, 'service[nginx]', :delayed
end

virtualhost         = '/etc/nginx/sites-available/default'
virtualhost_link    = '/etc/nginx/sites-enabled/default'

template virtualhost do
  source    "default.erb"
end

link virtualhost_link do
  to virtualhost
  notifies :reload, 'service[nginx]', :delayed
end

include_recipe "nginx::certs"