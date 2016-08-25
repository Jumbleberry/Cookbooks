include_recipe "apt"
include_recipe "ulimit"
# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

# install dependencies
node['nginx_swarm']['deps'].each do |dep|
    apt_package dep do
        action :install
    end
end

# Configure memcached
service "memcached" do
    action :nothing
end
cookbook_file 'memcached.conf' do
  source 'memcached.conf'
  path '/etc/memcached.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[memcached]', :immediate
end

# Install PCRE
remote_file '/tmp/pcre-8.39.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/pcre-8.39.tar.gz?raw=true'
    action :create
    notifies :run, 'execute[pcre]', :immediate
end
execute 'pcre' do
  command <<-EOH
    rm -rf pcre-8.39
    tar xzvf pcre-8.39.tar.gz
    cd pcre-8.39
    ./configure
    make
    sudo make install
  EOH
  cwd '/tmp'
  action :nothing
end

# Install zlib
remote_file '/tmp/zlib-1.2.8.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/zlib-1.2.8.tar.gz?raw=true'
    action :create
    notifies :run, 'execute[zlib]', :immediate
end
execute 'zlib' do
  command <<-EOH
    rm -rf zlib-1.2.8
    tar -zxf zlib-1.2.8.tar.gz
    cd zlib-1.2.8
    ./configure
    make
    sudo make install
    EOH
  cwd '/tmp'
  action :nothing
end

# Install openssl
remote_file '/tmp/openssl-1.0.2h.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/openssl-1.0.2h.tar.gz?raw=true'
    action :create
    notifies :create, 'cookbook_file[openssl_chacha.patch]', :immediate
    notifies :run, 'execute[openssl]', :immediate
end
cookbook_file 'openssl_chacha.patch' do
  source 'openssl_chacha.patch'
  path '/tmp/openssl_chacha.patch'
  owner 'root'
  group 'root'
  mode '0644'
  action :nothing
end
execute 'openssl' do
  command <<-EOH
    rm -rf openssl-1.0.2h
    tar -zxf openssl-1.0.2h.tar.gz
    cd openssl-1.0.2h
    patch -d . -p 1 < /tmp/openssl_chacha.patch
    ./config --prefix=/usr
    make
    sudo make install
    EOH
  cwd '/tmp'
  action :nothing
end

# Install pagespeed
remote_file '/tmp/release-1.11.33.3-beta.zip' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/release-1.11.33.3-beta.zip?raw=true'
    action :create
    notifies :run, 'execute[pagespeed]', :immediate
end
execute 'pagespeed' do
  command <<-EOH
    rm -rf ngx_pagespeed-release-1.11.33.3-beta
    unzip release-1.11.33.3-beta.zip
    EOH
  cwd '/tmp'
  action :nothing
  notifies :create, 'remote_file[psol]', :immediate
end
remote_file 'psol' do
    path '/tmp/ngx_pagespeed-release-1.11.33.3-beta/1.11.33.3.tar.gz'
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/1.11.33.3.tar.gz?raw=true'
    action :create
    only_if { ::File.directory?('/tmp/ngx_pagespeed-release-1.11.33.3-beta/') }
    notifies :run, 'execute[psol]', :immediate
end
execute 'psol' do
  command <<-EOH
    tar -xzvf 1.11.33.3.tar.gz
    EOH
  cwd '/tmp/ngx_pagespeed-release-1.11.33.3-beta'
  action :nothing
end

# Install nginx
["file", "memory"].each do |type|
    directory '/cache/ps/' + type do
        owner 'www-data'
        group 'www-data'
        mode 0644
        action :create
    end
end
remote_file '/tmp/nginx-1.9.7.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx-1.9.7.tar.gz?raw=true'
    action :create
    notifies :create, 'cookbook_file[nginx_dynamic_tls.patch]', :immediate
    notifies :create, 'cookbook_file[nginx_http2_spdy.patch]', :immediate
    notifies :run, 'execute[nginx]', :immediate
    notifies :enable, 'service[nginx]', :immediate
    notifies :start, 'service[nginx]', :immediate
    notifies :reload, 'service[nginx]', :immediate

end
cookbook_file 'nginx_http2_spdy.patch' do
  source 'nginx_http2_spdy.patch'
  path '/tmp/nginx_http2_spdy.patch'
  owner 'root'
  group 'root'
  mode '0644'
  action :nothing
end
cookbook_file 'nginx_dynamic_tls.patch' do
  source 'nginx_dynamic_tls.patch'
  path '/tmp/nginx_dynamic_tls.patch'
  owner 'root'
  group 'root'
  mode '0644'
  action :nothing
end
execute 'nginx' do
  command <<-EOH
    rm -rf nginx-1.9.7
    tar -zxf nginx-1.9.7.tar.gz
    cd nginx-1.9.7/
    patch -d . -p 1 < /tmp/nginx_http2_spdy.patch
    patch -d . -p 1 < /tmp/nginx_dynamic_tls.patch
    ./configure \
--sbin-path=/etc/nginx/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/etc/nginx/nginx.pid \
--with-pcre=/tmp/pcre-8.39 \
--with-zlib=/tmp/zlib-1.2.8 \
--with-http_ssl_module \
--with-stream \
--with-http_spdy_module \
--with-http_v2_module \
--with-threads \
--with-file-aio \
--with-openssl=/tmp/openssl-1.0.2h \
--user=www-data \
--group=www-data \
--add-module=/tmp/ngx_pagespeed-release-1.11.33.3-beta
    make
    sudo make install
    ln -fs /etc/nginx/nginx /usr/bin/nginx
    EOH
  cwd '/tmp'
  action :nothing
end
cookbook_file 'dhparam.pem' do
  source 'dhparam.pem'
  path '/etc/nginx/dhparam.pem'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
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
end
template 'nginx.conf' do
  path '/etc/nginx/nginx.conf'
  source 'nginx.conf.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  action :create
  notifies :enable, 'service[nginx]', :immediate
  notifies :start, 'service[nginx]', :immediate
  notifies :reload, 'service[nginx]', :immediate
end
service "nginx" do 
    provider Chef::Provider::Service::Upstart
    action :nothing
end