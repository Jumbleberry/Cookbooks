include_recipe "nginx"

# Checkout the gearman-ui repo
git "/var/www/gearman-ui" do
    repository "https://github.com/Jumbleberry/gearmanui.git"
    revision "master"
    user 'root'
    action :sync
end

# Update default nginx file

# Add the composer.lock file - takes forever to build otherwise...
cookbook_file "composer.lock" do
    path "/var/www/gearman-ui/composer.lock"
    owner "www-data"
    group "www-data"
    mode "0755"
end

# Install composer files
execute "composer install" do
    cwd "/var/www/gearman-ui"
    user "root"
    action :run
end

# And add the configuration file
template "/var/www/gearman-ui/gearmanui.yml" do
    source "gearmanui.yml.erb"
end

#Override service resolution
template "/var/www/gearman-ui/src/GearmanUI/ConfigurationProvider.php" do
    source "ConfigurationProvider.php.erb"
end