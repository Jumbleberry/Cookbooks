include_recipe "github-auth"
include_recipe "nodejs"

git node['titan']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/titan-app_wrapper.sh"
  repository node['titan']['git-url']
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

# Execute build tools
execute "gulp-build" do
  command "node node_modules/gulp/bin/gulp.js"
  user "root"
  cwd node['titan']['path']
  action :run
end
