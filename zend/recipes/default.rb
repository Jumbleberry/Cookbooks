# Make sure directory exists
directory "/var/www/lib/zf1" do
  owner node["user"]
  group node["user"]
  recursive true
end

# Checkout ZF1
git "/var/www/lib/zf1" do
  repository "git://github.com/zendframework/zf1.git"
  reference "master"
  action :sync
end