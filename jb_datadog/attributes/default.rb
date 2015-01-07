default['datadog']['templateDir'] = '/etc/dd-agent/conf.d'

default['datadog']['nginx']['instances'] = [
  {
    'nginx_status_url' => "http://localhost:80/nginx_status/",
    'tags'             => ["prod"]
  }
]

default['datadog']['redisdb']['instances'] = [
  {
    'server' => 'localhost',
    'port'   => '6379',
    'tags'   => ['prod']
  }
]

default['datadog']['gearmand']['instances'] = [
  {
    'server' => "localhost",
    'port'   => '4730',
    'tags'   => ["prod"]
  }
]

default['datadog']['mysql']['instances'] = [
  {
    'server'  => "read1.mysql.jumbleberry.com",
    'user'    => "root",
    'pass'    => "jbdb5s2013",
    'tags'    => ["prod"],
  }
]