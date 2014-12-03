# Add Mariadb repositories
apt_repository 'mariadb' do
  uri           node['mariadb']['ppa']['url']
  distribution  node['mariadb']['ppa']['distribution']
  components    node['mariadb']['ppa']['components']
  keyserver     node['mariadb']['ppa']['keyserver']
  key           node['mariadb']['ppa']['key']
end

# Install Mariadb
package 'mariadb-server' do
  action :install
  version node['mariadb']['version']
end

template '/etc/mysql/my.cnf' do
  source 'mariadb/my.cnf.erb'
  variables ({
      "bind_address" => node['mariadb']['myconf']['bind-address']
    })
end

#Enable remote access
remote_user = node['mariadb']['remote']['user']
remote_host = node['mariadb']['remote']['host']
execute 'enable root remote access' do
  command "mysql -uroot -e \"GRANT ALL PRIVILEGES ON *.* TO '#{remote_user}'@'#{remote_host}' WITH GRANT OPTION;\" "
end

template '/tmp/database-schema.sql' do
  source 'jbx/database-schema.sql.erb'
  variables({
    'dbname' => node['jbx']['db']['dbname'],
    'charset' => node['jbx']['db']['charset'],
    'collate' => node['jbx']['db']['collate']
  })
end

#Import mysql data
template '/tmp/database-data.sql' do
  source 'jbx/database-data.sql.erb'
    variables({
    'dbname' => node['jbx']['db']['dbname']
  })
end

#Creates jbx database
execute 'Database initialization' do
  cwd '/tmp'
  command "mysql -uroot < database-schema.sql"
  not_if "mysql -uroot -e 'use #{node['jbx']['db']['dbname']}'"
end

execute 'Database Import' do
  cwd '/tmp'
  command "mysql -uroot < database-data.sql; true"
end

# Restarts nginx service
service 'mysql' do
  action :restart
end
