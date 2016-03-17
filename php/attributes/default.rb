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
      "name" => "language-pack-en-base",
      "version" => "*"
  },
  {
    "name" => "php7.0-fpm",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-mysql",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-mcrypt",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-cli",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-dev",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-curl",
    "version" => "7.*"
  },
  {
      "name" => "php7.0-gd",
      "version" => "*"
  },
  {
      "name" => "php7.0-json",
      "version" => "*"
  }
]



#  {
#    "name" => "php5-mysqlnd",
#    "version" => "5.5.*"
#  },