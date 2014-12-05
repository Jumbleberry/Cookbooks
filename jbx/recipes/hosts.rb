#Update application credentials
credentials_file = "#{node['jbx']['core']['path']}/config/credentials.json"
credentials_file_template = "credentials.json.erb"

template credentials_file do
  source credentials_file_template
  variables ({
      "mysql_read_host"         => 'read1.mysql.jumbleberry.com',
      "mysql_read_username"     => node['jbx']['credentials']['mysql_read']['username'],
      "mysql_read_password"     => node['jbx']['credentials']['mysql_read']['password'],
      "mysql_read_database"     => node['jbx']['credentials']['mysql_read']['dbname'],

      "mysql_write_host"        => 'write1.mysql.jumbleberry.com',
      "mysql_write_username"    => node['jbx']['credentials']['mysql_write']['username'],
      "mysql_write_password"    => node['jbx']['credentials']['mysql_write']['password'],
      "mysql_write_database"    => node['jbx']['credentials']['mysql_write']['dbname'],

      "hitpath_host"            => node['jbx']['credentials']['hitpath']['host'],
      "hitpath_username"        => node['jbx']['credentials']['hitpath']['username'],
      "hitpath_password"        => node['jbx']['credentials']['hitpath']['password'],
      "hitpath_database"        => node['jbx']['credentials']['hitpath']['dbname'],

      "redis_host"              => 'read1.redis.jumbleberry.com',
      "redis_port"              => node['jbx']['credentials']['redis']['port'],

      "crypt"                   => node['jbx']['credentials']['crypt'],
      "raygun"                  => node['jbx']['credentials']['raygun']
    })
end