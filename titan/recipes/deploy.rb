include_recipe "github-auth"
include_recipe "nodejs"

# Set the branch to checkout
branch = ENV['JBX_TITAN_BRANCH'] || node['jbx']['titan-app']['branch']

git node['jbx']['titan-app']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/titan-app_wrapper.sh"
  repository node['jbx']['titan-app']['git-url']
  revision branch
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['titan']['user']}:#{node['titan']['user']} #{node['titan']['path']}"
  user "root"
  action :run
end

# Install node dependencies
execute "npm-dependencies" do
  command "npm install"
  user "root"
  cwd node['titan']['path']
  action :run
end

# Install gulp
execute "npm-gulp-install" do
  command "npm install -g gulp"
  user "root"
  cwd node['titan']['path']
  action :run
end

# Clean gulp
execute "npm-gulp-clean" do
  command "gulp clean"
  user "root"
  cwd node['titan']['path']
  action :run
end

# Build gulp
execute "npm-gulp-build" do
  command "gulp"
  user "root"
  cwd node['titan']['path']
  action :run
end
