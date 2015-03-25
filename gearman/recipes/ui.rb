include_recipe "nginx"

# Checkout the gearman-ui repo
git "/var/www/gearman-ui" do
    repository "git://github.com/gaspaio/gearmanui.git"
    checkout_branch "gearman-ui"
    action :sync
end

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
template "/var/www/gearman-ui/app/config/gearmanui.yml" do
    source "gearmanui.yml.erb"
end