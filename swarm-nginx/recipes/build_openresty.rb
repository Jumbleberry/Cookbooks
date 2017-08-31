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
remote_file '/tmp/pcre-8.41.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/pcre-8.41.tar.gz?raw=true'
    action :create
    notifies :run, 'execute[pcre]', :immediate
end
execute 'pcre' do
  command <<-EOH
    rm -rf pcre-8.41
    tar xzvf pcre-8.41.tar.gz
    cd pcre-8.41
    ./configure
    make
    sudo make install
  EOH
  cwd '/tmp'
  action :nothing
  notifies :touch, 'remote_file[openresty]', :delayed
end

# Install zlib
remote_file '/tmp/zlib-1.2.11.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/zlib-1.2.11.tar.gz?raw=true'
    action :create
    notifies :run, 'execute[zlib]', :immediate
end
execute 'zlib' do
  command <<-EOH
    rm -rf zlib-1.2.11
    tar -zxf zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure
    make
    sudo make install
    EOH
  cwd '/tmp'
  action :nothing
  notifies :touch, 'remote_file[openresty]', :delayed
end

# Install openssl
remote_file '/tmp/openssl-1.0.2l.tar.gz' do
    source 'https://github.com/Jumbleberry/NginxSwarm/blob/master/openssl-1.0.2l.tar.gz?raw=true'
    action :create
    notifies :run, 'execute[openssl]', :immediate
end
execute 'openssl' do
  command <<-EOH
    rm -rf openssl-1.0.2l
    tar -zxf openssl-1.0.2l.tar.gz
    cd openssl-1.0.2l
    ./config --prefix=/usr
    make
    sudo make install
    EOH
  cwd '/tmp'
  action :nothing
  notifies :touch, 'remote_file[openresty]', :delayed
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
  notifies :touch, 'remote_file[openresty]', :delayed
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
  notifies :touch, 'remote_file[openresty]', :delayed
end

# Install openresty
remote_file 'openresty' do
    path '/tmp/openresty-1.11.2.5.tar.gz'
    source 'https://github.com/Jumbleberry/NginxSwarm/raw/master/openresty-1.11.2.5.tar.gz'
    action :create
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
execute 'openresty' do
  command <<-EOH
    rm -rf openresty-1.11.2.5
    tar -zxf openresty-1.11.2.5.tar.gz
    cd openresty-1.11.2.5
    patch -d ./bundle/nginx-1.11.2 -p 0 < /tmp/nginx_upstream_check_module-master/check_1.11.1+.patch
    echo "3" > /proc/sys/net/ipv4/tcp_fastopen
    ./configure \
--prefix=/usr/local/openresty \
--error-log-path=/var/log/nginx/error_log \
--http-log-path=/var/log/nginx/access_log \
--sbin-path=/etc/nginx/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/run/nginx.pid \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-scgi-temp-path=/var/lib/nginx/scgi \
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--with-ipv6 \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_secure_link_module \
--with-http_random_index_module \
--with-http_gzip_static_module \
--with-http_sub_module \
--with-pcre=/tmp/pcre-8.41 \
--with-zlib=/tmp/zlib-1.2.11 \
--with-http_ssl_module \
--with-stream_ssl_module \
--with-stream \
--with-http_v2_module \
--with-threads \
--with-file-aio \
--with-http_stub_status_module \
--with-pcre-jit \
--with-http_realip_module \
--with-openssl=/tmp/openssl-1.0.2l \
--user=www-data \
--group=www-data \
--add-module=/tmp/nginx-upstream-dynamic-servers-master \
--add-module=/tmp/nginx_upstream_check_module-master \
--with-cc-opt='-O2  -DTCP_FASTOPEN=23 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' && \
    make && \
    make install && \
    ln -fs /etc/nginx/nginx /usr/bin/nginx
    EOH
  cwd '/tmp'
  action :run
end