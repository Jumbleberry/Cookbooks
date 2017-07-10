default['swarm_php']['composer_download_path'] = '/tmp/composer-install.php'

default['swarm_php']['fpm']['display_errors'] = 'Off'
default['swarm_php']['fpm']['listen'] = '0.0.0.0:9000'
default['swarm_php']['fpm']['pm'] = 'dynamic'
default['swarm_php']['fpm']['max_children'] = '256'
default['swarm_php']['fpm']['start_servers'] = '64'
default['swarm_php']['fpm']['min_spare_servers'] = '32'
default['swarm_php']['fpm']['max_spare_servers'] = '128'
default['swarm_php']['fpm']['include_path'] = '.:/usr/share/php:/var/www/lib'

default['swarm_php']['fpm']['conf_dirs'] = ['/etc/php/7.0/mods-available']
default['swarm_php']['fpm']['conf_dirs_alias'] = ['/etc/php/7.0/cli/conf.d', '/etc/php/7.0/fpm/conf.d']

default['swarm_php']['packages'] = [
  { 
      "name" => "language-pack-en-base",
      "version" => "*"
  },
  {
    "name" => "php7.0-fpm",
    "version" => "*"
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
    "name" => "php7.0",
    "version" => "7.*"
  },
  {
    "name" => "php7.0-curl",
    "version" => "7.*"
  },
  {
      "name" => "php7.0-json",
      "version" => "*"
  },
  {
      "name" => "php7.0-mbstring",
      "version" => "*"
  }
]