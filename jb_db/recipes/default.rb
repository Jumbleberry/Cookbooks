# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

# Set mysql server default password
root_password = "#{node['jbx']['credentials']['mysql_read']['password']}"
execute "mysql-default-password" do
    command "echo \"mysql-server-5.6 mysql-server/root_password password #{root_password}\" | debconf-set-selections"
    user 'root'
end
execute "mysql-default-password-again" do
    command "echo \"mysql-server-5.6 mysql-server/root_password_again password #{root_password}\" | debconf-set-selections"
    user 'root'
end

# Install mysql server 5.6
apt_package 'mysql-server-5.6' do
    action :install
end

# Copy config file
cookbook_file "/etc/mysql/my.cnf" do
    source "mysql/my.cnf"
    owner "root"
    group "root"
    mode "0644"
end

# Restart mysql
execute "mysql-restart" do
    command "service mysql restart"
    user 'root'
end

# Create jbx user
query = "CREATE USER \'jbx\'@\'%\' IDENTIFIED BY \'#{node['jbx']['credentials']['mysql_read']['password']}\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root -p#{node['jbx']['credentials']['mysql_read']['password']}"
end

query = "GRANT ALL ON *.* TO \'jbx\'@\'%\'"
execute 'grantPermissions' do
    command "echo \"#{query}\" | mysql -u root -p#{node['jbx']['credentials']['mysql_read']['password']}"
end

# Create 'root'@'%'
query = "CREATE USER \'root\'@\'%\' IDENTIFIED BY \'#{node['jbx']['credentials']['mysql_read']['password']}\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root -p#{node['jbx']['credentials']['mysql_read']['password']}"
end
query = "GRANT ALL ON *.* TO \'root\'@\'%\'"
execute 'grantPermissions' do
    command "echo \"#{query}\" | mysql -u root -p#{node['jbx']['credentials']['mysql_read']['password']}"
end

include_recipe "nginx"
include_recipe "php"

# Install phpmyadmin
apt_package 'phpmyadmin' do
    action :install
end

# Copy phpmyadmin config file
cookbook_file "/etc/phpmyadmin/config.inc.php" do
    source "phpmyadmin/config.inc.php"
    owner "root"
    group "root"
    mode "0644"
end

# Copy phpmyadmin table dump
cookbook_file "/tmp/create_tables.sql" do
    source "phpmyadmin/create_tables.sql"
    owner "root"
    group "root"
    mode "0644"
end

# Restore phpmyadmin tables
execute "phpmyadmin" do
    command "mysql -u root -p#{node['jbx']['credentials']['mysql_read']['password']} < /tmp/create_tables.sql"
end

# Symlink myadmin to somewhere sensible
link "/var/www/phpmyadmin" do
    to "/usr/share/phpmyadmin"
    action :create
end

# Copy myadmin config
template "/var/www/phpmyadmin/config.inc.php" do
  source  "phpmyadmin/config.inc.php.erb"
end

# Create nginx config file
template "/etc/nginx/sites-available/phpmyadmin" do
  source  "nginx/phpmyadmin.erb"
end

link "/etc/nginx/sites-enabled/phpmyadmin" do
    to "/etc/nginx/sites-available/phpmyadmin"
    action :create
end

# Reload nginx
service "nginx" do
    supports :status => true, :restart => true, :start => true, :stop => true
    action :restart
end

# Install awscli
include_recipe "awscli"
template "/home/vagrant/.aws/config" do
    source "aws/config"
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "provate_key" => node['aws']['aws_secret_access_key']
    })
end

# Install JB DB Importer
directory "#{default['jbdb_importer']['source_directory']}" do
    action :create
end

template "#{default['jbdb_importer']['source_directory']}/jbdb_import" do
    source "jbdb_import"
    variables ({
        "username"  => default['mysql']['server_root_user'],
        "password"  => default['mysql']['server_root_password'],
        "s3_bucket" => default['aws']['db_bucket']
    })
end

link "#{default['jbdb_importer']['source_directory']}/jbdb_import" do
    to "#{default['jbdb_importer']['bin_directory']}/jbdb_import"
    action :create
end