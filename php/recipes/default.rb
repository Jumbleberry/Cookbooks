# Custom repositories
apt_repository 'php-ppa' do
  uri           'ppa:ondrej/php'
  distribution  node['lsb']['codename']
  components    ['main']
end

include_recipe "apt"
execute "apt-get-update-periodic-php" do
    command "apt-get update"
    user 'root'
end

# Installs php package and modules
phpmodules = node['php']['packages']
phpmodules.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
    # Ignore configuration changes - necessary because of nginx updates
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes'
  end
end

# Creates symlinks for the configurations files
node['php']['fpm']['conf_dirs'].each do |conf_dir|
    cookbook_file "#{conf_dir}/#{node['php']['fpm']['conf_file']}" do
        source "redis.ini"
        owner "root"
        group "root"
        mode 0644
    end

    node['php']['fpm']['conf_dirs_alias'].each do |conf_dirs_alias|
        link "#{conf_dirs_alias}/20-#{node['php']['fpm']['conf_file']}" do
          to "#{conf_dir}/#{node['php']['fpm']['conf_file']}"
          notifies :restart, "service[php7.1-fpm]", :delayed
        end
    end
end

#Register Php service
service 'php7.1-fpm' do
  case node['platform']
  when 'ubuntu'
    if node['lsb']['codename'] == 'trusty'
      provider Chef::Provider::Service::Upstart
    end
  end
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

#Check if we need to change the php include path
include_path = node['php']['fpm']['include_path']

directory '/var/log/php/' do
    owner 'www-data'
    group 'www-data'
end

file '/var/log/php/error.log' do
    owner 'www-data'
    group 'www-data'
    action :create_if_missing
end

#Fpm configurations
template '/etc/php/7.1/fpm/php.ini' do
  source 'fpm/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors'],
    'include_path' => include_path
  })
  notifies :restart, "service[php7.1-fpm]", :delayed
end

template '/etc/php/7.1/fpm/pool.d/www.conf' do
  source 'fpm/www.conf.erb'
  variables({
    'listen' => node['php']['fpm']['listen'],
    'pm' => node['php']['fpm']['pm'],
    'max_children' => node['php']['fpm']['max_children'],
    'start_servers' => node['php']['fpm']['start_servers'],
    'min_spare_servers' => node['php']['fpm']['min_spare_servers'],
    'max_spare_servers' => node['php']['fpm']['max_spare_servers']
  })
  notifies :restart, "service[php7.1-fpm]", :delayed
end

#Cli Configurations
template '/etc/php/7.1/cli/php.ini' do
  source 'cli/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors'],
    'include_path' => include_path
  })
end

#Install composer
composer_download_path = node['php']['composer_download_path']
if composer_download_path
  remote_file composer_download_path do
    source 'https://getcomposer.org/installer'
    not_if { ::File.exists?("/usr/local/bin/composer")}
  end

  bash 'install composer' do
    cwd '/tmp'
    code <<-EOL
      php composer-install.php
      mv composer.phar /usr/local/bin/composer
    EOL
    not_if { ::File.exists?("/usr/local/bin/composer")}
  end
end
