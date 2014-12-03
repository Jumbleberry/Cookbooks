#Xdebug package
package "php5-xdebug" do
  action :install
end

#Xdebug configuration
template '/etc/php5/mods-available/xdebug.ini' do
  source    "xdebug.ini.erb"
  notifies :restart, "service[php5-fpm]", :delayed
end
