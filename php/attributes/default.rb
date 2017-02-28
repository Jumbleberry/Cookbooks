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
    "name" => "php5.6-fpm",
    "version" => "*"
  },
  {
    "name" => "php5.6-common",
    "version" => "*"
  },
  {
    "name" => "php5.6-mysql",
    "version" => "*"
  },
  {
    "name" => "php5.6-mcrypt",
    "version" => "*"
  },
  {
    "name" => "php5.6-zip",
    "version" => "*"
  },
  {
    "name" => "php5.6-memcache",
    "version" => "*"
  },
  {
    "name" => "php5.6-cli",
    "version" => "*"
  },
  {
    "name" => "php5.6-xml",
    "version" => "*"
  },
  {
    "name" => "php5.6-dev",
    "version" => "*"
  },
  {
    "name" => "php5.6-bcmath",
    "version" => "*"
  },
  {
    "name" => "php5.6-redis",
    "version" => "*"
  },
  {
    "name" => "php5.6-xcache",
    "version" => "*"
  },
  {
    "name" => "php5.6-gearman",
    "version" => "*"
  },
  {
    "name" => "php5.6-curl",
    "version" => "*"
  },
  {
    "name" => "php5.6-mbstring",
    "version" => "*"
  },
  {
    "name" => "php-gettext",
    "version" => "*"
  },
  {
    "name" => "php5-gd",
    "version" => "*"
  }
]



#  {
#    "name" => "php5-mysqlnd",
#    "version" => "5.6.*"
#  },