# Redis package
package 'redis-server' do
  action :install
  version node["redis"]["version"]
end

#Redis service
service 'redis-server' do
  action :nothing
end

#Redis configuration
template '/etc/redis/redis.conf' do
  source    "redis.conf.erb"
  notifies :restart, "service[redis-server]", :delayed
end
