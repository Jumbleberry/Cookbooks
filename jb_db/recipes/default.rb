# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

# Install mysql server 5.6
execute "mysql-install" do
    command "(export DEBIAN_FRONTEND=\"noninteractive\"; sudo -E apt-get install -y -q mysql-server-5.6)"
    user "root"
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
query = "GRANT ALL ON *.* TO \'jbx\'@\'%\' IDENTIFIED BY \'\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root"
end

# Create 'root'@'%'
query = "GRANT ALL ON *.* TO \'root\'@\'%\' IDENTIFIED BY \'\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root"
end

include_recipe "nginx"
include_recipe "php"

# Install phpmyadmin
apt_package 'phpmyadmin' do
    action :install
end

# Copy phpmyadmin config file
cookbook_file "/etc/phpmyadmin/config.inc.php" do
    source "phpmyadmin/etc-config.inc.php"
    owner "root"
    group "root"
    mode "0644"
end

# I don't know why phpmyadmin has so many different configs in so many different directories
cookbook_file "/var/lib/phpmyadmin/config.inc.php" do
    source "phpmyadmin/var-config.inc.php"
    owner "www-data"
    group "www-data"
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
    command "mysql -u root < /tmp/create_tables.sql"
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
template "/home/#{node['user']}/.aws/config" do
    source "aws/config.erb"
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "private_key" => node['aws']['aws_secret_access_key']
    })
end

# Create credentials for root user
directory "/root/.aws" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
end
template "/root/.aws/config" do
    source "aws/config.erb"
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "private_key" => node['aws']['aws_secret_access_key']
    })
end

# Install JB DB Importer
directory node['jbdb_importer']['source_directory'] do
    action :create
end

template "#{node['jbdb_importer']['source_directory']}/jbdb_import" do
    source "jbdb_import.erb"
    variables ({
        "username"  => 'root',
        "password"  => '',
        "s3_bucket" => node['aws']['db_bucket']
    })
    mode "0755"
end

link "#{node['jbdb_importer']['bin_directory']}/jbdb_import" do
    to "#{node['jbdb_importer']['source_directory']}/jbdb_import"
end

# Create JBX
execute "restore-JBX-DB" do
    command "jbdb_import jbx --create"
end

# Create Gearman
execute "restore-gearman-DB" do
    command "jbdb_import gearman --gearman"
end
