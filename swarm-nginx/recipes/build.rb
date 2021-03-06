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
  notifies :touch, 'remote_file[nginx]', :delayed
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
  notifies :touch, 'remote_file[nginx]', :delayed
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
  notifies :touch, 'remote_file[nginx]', :delayed
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
    find . -type f -exec sed -i 's/ngx_pagespeed_beacon/swarm_radar/g' {} +
    EOH
  cwd '/tmp/ngx_pagespeed-release-1.11.33.3-beta'
  action :nothing
  notifies :touch, 'remote_file[nginx]', :delayed
end

# Install dynamic upstream
remote_file '/tmp/nginx-upstream-dynamic-servers-master.zip' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx-upstream-dynamic-servers-master.zip?raw=true'
    action :create
    notifies :run, 'execute[upstream]', :immediate
end
execute 'upstream' do
  command <<-EOH
    rm -rf nginx-upstream-dynamic-servers-master
    unzip nginx-upstream-dynamic-servers-master.zip
    EOH
  cwd '/tmp'
  action :nothing
  notifies :touch, 'remote_file[nginx]', :delayed
end

# Install upstream check
remote_file '/tmp/nginx_upstream_check_module.zip' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx_upstream_check_module.zip?raw=true'
    action :create
    notifies :run, 'execute[check]', :immediate
end
execute 'check' do
  command <<-EOH
    rm -rf nginx_upstream_check_module-master
    unzip nginx_upstream_check_module.zip
    EOH
  cwd '/tmp'
  action :nothing
  notifies :touch, 'remote_file[nginx]', :delayed
end

# Install nginx
remote_file 'nginx' do
    path '/tmp/nginx-1.9.7.tar.gz'
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx-1.9.7.tar.gz?raw=true'
    action :create
    notifies :create, 'cookbook_file[nginx_dynamic_tls.patch]', :delayed
    notifies :create, 'cookbook_file[nginx_http2_spdy.patch]', :delayed
    notifies :create, 'cookbook_file[ssi.patch]', :delayed
    notifies :run, 'execute[nginx]', :delayed
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
cookbook_file 'ssi.patch' do
  source 'ssi.patch'
  path '/tmp/ssi.patch'
  owner 'root'
  group 'root'
  mode '0644'
  action :nothing
end
cookbook_file '30-tcp_fastopen.conf' do
  source '30-tcp_fastopen.conf'
  path '/etc/sysctl.d/30-tcp_fastopen.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
directory '/var/log/nginx' do
    owner 'www-data'
    group 'www-data'
    mode 0644
    action :create
    recursive true
end
execute 'nginx' do
  command <<-EOH
    rm -rf nginx-1.9.7
    tar -zxf nginx-1.9.7.tar.gz
    cd nginx-1.9.7/
    patch -d . -p 1 < /tmp/nginx_http2_spdy.patch
    patch -d . -p 1 < /tmp/nginx_dynamic_tls.patch
    patch -d . -p 1 < /tmp/ssi.patch
    patch -d . -p 0 < /tmp/nginx_upstream_check_module-master/check_1.9.2+.patch
    echo "3" > /proc/sys/net/ipv4/tcp_fastopen
    ./configure \
--prefix=/usr/local/nginx \
--error-log-path=/var/log/nginx/error_log \
--http-log-path=/var/log/nginx/access_log \
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
--with-http_stub_status_module \
--with-pcre-jit \
--with-http_gzip_static_module \
--with-openssl=/tmp/openssl-1.0.2h \
--user=www-data \
--group=www-data \
--add-module=/tmp/ngx_pagespeed-release-1.11.33.3-beta \
--add-module=/tmp/nginx-upstream-dynamic-servers-master \
--add-module=/tmp/nginx_upstream_check_module-master \
--with-cc-opt='-O2  -DTCP_FASTOPEN=23 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic'
    make
    sudo make install
    ln -fs /etc/nginx/nginx /usr/bin/nginx
    EOH
  cwd '/tmp'
  action :nothing
  notifies :enable, 'service[nginx]', :delayed
  notifies :start, 'service[nginx]', :delayed
  notifies :reload, 'service[nginx]', :delayed
end