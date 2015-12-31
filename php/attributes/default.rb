default['php']['composer_download_path'] = '/tmp/composer-install.php'

default['php']['fpm']['display_errors'] = 'Off'
default['php']['fpm']['listen'] = '/var/run/php5-fpm.sock'
default['php']['fpm']['pm'] = 'dynamic'
default['php']['fpm']['max_children'] = '100'
default['php']['fpm']['start_servers'] = '40'
default['php']['fpm']['min_spare_servers'] = '20'
default['php']['fpm']['max_spare_servers'] = '40'
default['php']['fpm']['include_path'] = '.:/usr/share/php:/var/www/lib'

default['php']['packages'] = [
  {
    "name" => "php5-fpm",
    "version" => "5.5.*"
  },
  {
    "name" => "php5-mysql",
    "version" => "5.5.*"
  },
  {
    "name" => "php5-mcrypt",
    "version" => "5.5.*"
  },
  {
    "name" => "php5-memcache",
    "version" => "3.0.8*"
  },
  {
    "name" => "php5-cli",
    "version" => "5.5.*"
  },
  {
    "name" => "php5-dev",
    "version" => "5.5.*"
  },
  {
    "name" => "php5-redis",
    "version" => "2.2.*"
  },
  {
    "name" => "php5-xcache",
    "version" => "3.2.0*"
  },
  {
    "name" => "php5-gearman",
    "version" => "1.1.2*"
  },
  {
    "name" => "php5-curl",
    "version" => "5.5.*"
  },
  {
      "name" => "php5-gd",
      "version" => "*"
   }
]



#  {
#    "name" => "php5-mysqlnd",
#    "version" => "5.5.*"
#  },