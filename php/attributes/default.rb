default['php']['composer_download_path'] = '/tmp/composer-install.php'

default['php']['fpm']['display_errors'] = 'Off'
default['php']['fpm']['listen'] = '/var/run/php5-fpm.sock'
default['php']['fpm']['pm'] = 'dynamic'
default['php']['fpm']['max_children'] = '100'
default['php']['fpm']['start_servers'] = '40'
default['php']['fpm']['min_spare_servers'] = '20'
default['php']['fpm']['max_spare_servers'] = '40'
default['php']['fpm']['include_path'] = '.:/usr/share/php:/var/www/lib'

default['php']['fpm']['conf_dirs'] = ['/etc/php/7.1/mods-available']
default['php']['fpm']['conf_dirs_alias'] = ['/etc/php/7.1/cli/conf.d', '/etc/php/7.1/fpm/conf.d']
default['php']['fpm']['conf_file'] = 'redis.ini'

default['php']['packages'] = [
  {
    "name" => "php7.1-fpm",
    "version" => "*"
  },
  {
    "name" => "php7.1-common",
    "version" => "*"
  },
  {
    "name" => "php7.1-mysql",
    "version" => "*"
  },
  {
    "name" => "php7.1-mcrypt",
    "version" => "*"
  },
  {
    "name" => "php7.1-zip",
    "version" => "*"
  },
  {
    "name" => "php7.1-memcache",
    "version" => "*"
  },
  {
    "name" => "php7.1-cli",
    "version" => "*"
  },
  {
    "name" => "php7.1-apcu",
    "version" => "*"
  },
  {
    "name" => "php7.1-xml",
    "version" => "*"
  },
  {
    "name" => "php7.1-dev",
    "version" => "*"
  },
  {
    "name" => "php7.1-bcmath",
    "version" => "*"
  },
  {
    "name" => "php7.1-redis",
    "version" => "*"
  },
  {
    "name" => "php7.1-gearman",
    "version" => "*"
  },
  {
    "name" => "php7.1-curl",
    "version" => "*"
  },
  {
    "name" => "php7.1-mbstring",
    "version" => "*"
  },
  {
    "name" => "php7.1-gettext",
    "version" => "*"
  },
  {
    "name" => "php7.1-gd",
    "version" => "*"
  }
]



#  {
#    "name" => "php5-mysqlnd",
#    "version" => "7.1.*"
#  },
