default['phalcon']['packages'] = [
  {
      "name" => "libjson0",
      "version" => "*"
  },
  {
      "name" => "libjson0-dev",
      "version" => "*"
  },
  {
      "name" => "re2c",
      "version" => "*"
   }
]

default['phalcon']['git_url'] = 'https://github.com/phalcon/cphalcon.git'
default['phalcon']['git_ref'] = '2.1.x'
default['phalcon']['download_path'] = "/tmp/cphalcon"
default['phalcon']['build_path'] = "build"
default['phalcon']['conf_dirs'] = ['/etc/php/7.1/mods-available']
default['phalcon']['conf_dirs_alias'] = ['/etc/php/7.1/cli/conf.d', '/etc/php/7.1/fpm/conf.d']
default['phalcon']['conf_file'] = 'phalcon.ini'
default['phalcon']['devtools'] = false

default['zephir']['download_path'] = "/tmp/zephir"
default['zephir']['git_url'] = 'https://github.com/phalcon/zephir.git'
default['zephir']['revision'] = 'master'