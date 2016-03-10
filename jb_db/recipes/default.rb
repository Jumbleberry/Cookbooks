# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

include_recipe "nginx"
include_recipe "php"
include_recipe "mysql::server"

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