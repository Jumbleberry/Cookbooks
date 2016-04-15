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