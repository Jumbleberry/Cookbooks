# Make sure directory exists
directory "/var/www/lib/zf1" do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
  recursive true
end

# Checkout ZF1
git "/var/www/lib/zf1" do
  repository "git://github.com/zendframework/zf1.git"
  reference "master"
  action :sync
end