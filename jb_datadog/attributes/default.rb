default['datadog']['templateDir'] = '/etc/dd-agent/conf.d'

default['datadog']['nginx']['instances'] = [
  {
    'nginx_status_url' => "http://localhost:80/nginx_status/",
    'tags'             => ["prod"]
  }
]

default['datadog']['gearmand']['instances'] = [
  {
    'server' => node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first || node['ipaddress'],
    'port'   => '4730',
    'tags'   => ["prod"]
  }
]

default['datadog']['mysql']['instances'] = [
  {
    'server'  => node['jbx']['credentials']['mysql_read']['host'],
    'user'    => node['jbx']['credentials']['mysql_read']['username'],
    'pass'    => node['jbx']['credentials']['mysql_read']['password'],
    'tags'    => ["prod"],
  },
  {
    'server'  => node['jbx']['credentials']['mysql_write']['host'],
    'user'    => node['jbx']['credentials']['mysql_write']['username'],
    'pass'    => node['jbx']['credentials']['mysql_write']['password'],
    'tags'    => ["prod"],
  }
]

default['datadog']['redisdb']['instances'] = []

node['redisio']['servers'].each do | server |
  default['datadog']['redisdb']['instances'] << {
    'server' => 'localhost',
    'port'   => server.port,
    'tags'   => ["prod"]
  }
end