include_recipe "timezone-ii"
include_recipe "web-server"
include_recipe "github-auth"
include_recipe "nginx"
include_recipe "php"
include_recipe "phalcon"

# Set the branch to checkout
branch = ENV['JBX_CORE_BRANCH'] || node['jbx']['core']['branch']

# Make sure directory exists
directory node['jbx']['core']['path'] do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
end

git node['jbx']['core']['path'] do
  if !node['jbx']['core']['github_key'].empty?
    ssh_wrapper node['github-auth']['wrapper_path'] + "/" + node['jbx']['core']['github_key'] + "_wrapper.sh"
  end
  repository node['jbx']['core']['git-url']
  revision branch
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['core']['path']}"
  user "root"
  action :run
end

# Run the deploy script
execute 'Deploy Script' do
    cwd "#{node['jbx']['core']['path']}"
    user "root"
    command 'sh deploy.sh'
end

#Update application credentials
credentials_file = "#{node['jbx']['core']['path']}/config/credentials.json"
credentials_file_template = "credentials.json.erb"

template credentials_file do
  source credentials_file_template
  variables ({
      "mysql_read_host"         => node['jbx']['credentials']['mysql_read']['host'],
      "mysql_read_username"     => node['jbx']['credentials']['mysql_read']['username'],
      "mysql_read_password"     => node['jbx']['credentials']['mysql_read']['password'],
      "mysql_read_database"     => node['jbx']['credentials']['mysql_read']['dbname'],

      "mysql_write_host"        => node['jbx']['credentials']['mysql_write']['host'],
      "mysql_write_username"    => node['jbx']['credentials']['mysql_write']['username'],
      "mysql_write_password"    => node['jbx']['credentials']['mysql_write']['password'],
      "mysql_write_database"    => node['jbx']['credentials']['mysql_write']['dbname'],

      "hitpath_host"            => node['jbx']['credentials']['hitpath']['host'],
      "hitpath_username"        => node['jbx']['credentials']['hitpath']['username'],
      "hitpath_password"        => node['jbx']['credentials']['hitpath']['password'],
      "hitpath_database"        => node['jbx']['credentials']['hitpath']['dbname'],

      "redis_host"              => node['jbx']['credentials']['redis']['host'],
      "redis_port"              => node['jbx']['credentials']['redis']['port'],

      "crypt"                   => node['jbx']['credentials']['crypt'],
      "raygun"                  => node['jbx']['credentials']['raygun']
    })
end

# Run database migrations
execute 'Database migrations' do
  cwd "#{node['jbx']['core']['path']}/application/cli"
  command "php cli.php migrations:migrate --no-interaction"
  not_if { ::Dir.glob("#{node['jbx']['core']['path']}/application/migrations/*.php").empty? }
end
