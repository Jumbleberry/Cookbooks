include_recipe "github-auth"

# Set the branch to checkout
branch = ENV['JBX_CORE_BRANCH'] || node['jbx']['core']['branch']

# Make sure directory exists
directory node['jbx']['core']['path'] do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
end

{ :checkout => true, :sync => node[:user] != 'vagrant' }.each do |action, should|
    git node['jbx']['core']['path'] do
      ssh_wrapper node['github-auth']['wrapper_path'] + "/" + "core_wrapper.sh"
      repository node['jbx']['core']['git-url']
      revision branch
      user 'root'
      action action
      only_if { should }
    end
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['core']['path']}"
  user "root"
  action :run
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

      "hitpath_host"            => node['jbx']['credentials']['hitpath_read']['host'],
      "hitpath_username"        => node['jbx']['credentials']['hitpath_read']['username'],
      "hitpath_password"        => node['jbx']['credentials']['hitpath_read']['password'],
      "hitpath_database"        => node['jbx']['credentials']['hitpath_read']['dbname'],
      
      "hitpath_user"            => node['jbx']['credentials']['hitpath']['username'],
      "hitpath_pass"            => node['jbx']['credentials']['hitpath']['password'],
      "hitpath_id"              => node['jbx']['credentials']['hitpath']['hitpath_id'],
      "hitpath_aws_bucket"      => node['jbx']['credentials']['hitpath']['aws_bucket'],
      "hitpath_api_key"         => node['jbx']['credentials']['hitpath']['api_key'],

      "redis_read_host"         => node['jbx']['credentials']['redis_read']['host'],
      "redis_read_port"         => node['jbx']['credentials']['redis_read']['port'],
      "redis_read_index"        => node['jbx']['core']['redis_db'],
      "redis_write_host"        => node['jbx']['credentials']['redis_write']['host'],
      "redis_write_port"        => node['jbx']['credentials']['redis_write']['port'],
      "redis_write_index"       => node['jbx']['core']['redis_db'],
      
      "domains"                 => node['jbx']['credentials']['domains'].to_json,
      "mail"                    => node['jbx']['credentials']['mail'].to_json,
      
      "gearman_host"            => node['jbx']['credentials']['gearman']['external_host'],

      "crypt"                   => node['jbx']['credentials']['crypt'],
      "raygun"                  => node['jbx']['credentials']['raygun'],
      
      "aws_access_key"          => node['jbx']['credentials']['aws']['access_key'],
      "aws_secret_key"          => node['jbx']['credentials']['aws']['secret_key'],
                                
      "datadog_api_key"         =>  node['datadog']['api_key'],
      "datadog_app_key"         =>  node['datadog']['application_key'],
      
      "webdriver_user"          => node['web_driver']['user'],
      "webdriver_password"      => node['web_driver']['password'],
      "webdriver_url"           => node['web_driver']['url'],

      "alchemy_free"            => node['jbx']['credentials']['alchemy']['free'],
      "alchemy_paid"            => node['jbx']['credentials']['alchemy']['paid'],
      
      "visualRecognition_free"  => node['jbx']['credentials']['visualRecognition']['free'],
      "visualRecognition_paid"  => node['jbx']['credentials']['visualRecognition']['paid'],
      
      "trackrevenue"            => node['jbx']['credentials']['trackrevenue']
    })
    not_if { node[:user] == 'vagrant' && ::File.exist?(credentials_file) }
end

template "#{node['jbx']['core']['path']}/config/modules.json" do
    source "modules.json.erb"
    not_if { node[:user] == 'vagrant' && ::File.exist?("#{node['jbx']['core']['path']}/config/modules.json") }
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
    cwd "#{node['jbx']['core']['path']}"
    user "root"
end

# Run database migrations
execute 'Database migrations' do
  cwd "#{node['jbx']['core']['path']}/application/cli"
  command "php cli.php migrations:migrate --no-interaction"
  not_if { ::Dir.glob("#{node['jbx']['core']['path']}/application/migrations/*.php").empty? }
end

# Add at allow file
cookbook_file "/etc/at.allow" do
    source "at/at.allow"
    owner "root"
    group "root"
    mode "0644"
end

cron "Core - Bin Number Scraper" do
  command "/usr/bin/php #{node['jbx']['core']['path']}/application/modules/api/crons/bin_numbers.php"
  minute '*'
  user 'www-data'
  action :delete
end
