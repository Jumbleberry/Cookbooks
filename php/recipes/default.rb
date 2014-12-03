# Installs php package and modules
phpmodules = node['php']['packages']
phpmodules.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
  end
end

#Register Php service
service 'php5-fpm' do
  action :nothing
end

#Fpm configurations
template '/etc/php5/fpm/php.ini' do
  source 'fpm/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors']
  })
  notifies :restart, "service[php5-fpm]", :delayed
end

template '/etc/php5/fpm/pool.d/www.conf' do
  source 'fpm/www.conf.erb'
  variables({
    'listen' => node['php']['fpm']['listen'],
    'max_children' => node['php']['fpm']['max_children'],
    'start_servers' => node['php']['fpm']['start_servers'],
    'min_spare_servers' => node['php']['fpm']['min_spare_servers'],
    'max_spare_servers' => node['php']['fpm']['max_spare_servers']
  })
  notifies :restart, "service[php5-fpm]", :delayed
end

#Cli Configurations
template '/etc/php5/cli/php.ini' do
  source 'cli/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors']
  })
end

#Install composer
composer_download_path = node['php']['composer_download_path']
if composer_download_path
  remote_file '/tmp/composer-install.php' do
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
