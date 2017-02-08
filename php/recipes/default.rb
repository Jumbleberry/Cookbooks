# Custom repositories
apt_repository 'php5.5-ppa' do
  uri           'ppa:ondrej/php'
  distribution  'precise'
  components    ['main', 'stable']
end

include_recipe "apt"

# Installs php package and modules
phpmodules = node['php']['packages']
phpmodules.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
    # Ignore configuration changes - necessary because of nginx updates
    options '--force-yes'
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
  end
end

# Symlink our config script
['fpm', 'mods-available', 'cli'].each do |dir|
    directory "/etc/php5/" + dir do
        action :delete
        recursive true
        not_if { File.symlink?("/etc/php5/" + dir) || !::Dir.exists?("/etc/php/5.6/" + dir) }
    end
        
    link "/etc/php5/" + dir do
        to "/etc/php/5.6/" + dir
        action :create
        owner "root"
        group "root"
        not_if { ::Dir.exists?("/etc/php5/" + dir) || !::Dir.exists?("/etc/php/5.6/" + dir) }
    end
end

execute 'php5.6-rename' do
    command <<-EOH
      cp /etc/init.d/php5.6-fpm /etc/init.d/php5-fpm
      update-rc.d -f php5.6-fpm remove
      rm -f /etc/init.d/php5.6-fpm
      mv /etc/init/php5.6-fpm.conf /etc/init/php5-fpm.conf
      update-rc.d php5-fpm defaults
    EOH
    only_if { ::File.exists?("/etc/init.d/php5.6-fpm")}
end

# Remove 5.6 service if it exists
service 'php5.6-fpm' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :stop
  ignore_failure true
  notifies :run, 'execute[php5.6-rename]', :immediately
end


#Register Php service
service 'php5-fpm' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :start
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
template '/etc/php5/fpm/php.ini' do
  source 'fpm/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors'],
    'include_path' => include_path
  })
  notifies :reload, "service[php5-fpm]", :delayed
end

template '/etc/php5/fpm/pool.d/www.conf' do
  source 'fpm/www.conf.erb'
  variables({
    'listen' => node['php']['fpm']['listen'],
    'pm' => node['php']['fpm']['pm'],
    'max_children' => node['php']['fpm']['max_children'],
    'start_servers' => node['php']['fpm']['start_servers'],
    'min_spare_servers' => node['php']['fpm']['min_spare_servers'],
    'max_spare_servers' => node['php']['fpm']['max_spare_servers']
  })
  notifies :reload, "service[php5-fpm]", :delayed
end

#Cli Configurations
template '/etc/php5/cli/php.ini' do
  source 'cli/php.ini.erb'
  variables({
    'display_errors' => node['php']['fpm']['display_errors'],
    'include_path' => include_path
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
