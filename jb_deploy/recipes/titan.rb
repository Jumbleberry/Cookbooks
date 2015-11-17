include_recipe "jb_deploy::core"
include_recipe "github-auth"

# Set the branch to checkout
branch = ENV['JBX_TITAN_BRANCH'] || node['jbx']['titan']['branch']

git node['jbx']['titan']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/titan_wrapper.sh"
  repository node['jbx']['titan']['git-url']
  revision branch
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['titan']['path']}"
  user "root"
  action :run
end

#Update application credentials
credentials_file = "#{node['jbx']['titan']['path']}/config/credentials.json"
credentials_file_template = "titan_credentials.json.erb"

template credentials_file do
  source credentials_file_template
  variables ({
      "mysql_write_host"        => node['jbx']['credentials']['titan']['host'],
      "mysql_write_username"    => node['jbx']['credentials']['titan']['username'],
      "mysql_write_password"    => node['jbx']['credentials']['titan']['password'],
      "mysql_write_database"    => node['jbx']['credentials']['titan']['dbname']
    })
end