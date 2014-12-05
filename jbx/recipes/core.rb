# Set the branch to checkout
branch = ENV['JBX_CORE_BRANCH'] || node['jbx']['core']['branch']

# Make sure directory exists
directory node['jbx']['core']['path'] do
  owner node["jbx"]["user"]
  group node["jbx"]["user"]
end

git node['jbx']['core']['path'] do
  if !node['jbx']['core']['github_key'].empty?
    ssh_wrapper node['github']['wrapper_path'] + "/" + node['jbx']['core']['github_key'] + "_wrapper.sh"
  end
  repository node['jbx']['core']['git-url']
  revision branch
  user node['jbx']['user']
  action :sync
end

# Run the deploy script
execute 'Deploy Script' do
    cwd "#{node['jbx']['core']['path']}"
    user "root"
    command 'sh deploy.sh'
end

# Run database migrations
execute 'Database migrations' do
  cwd "#{node['jbx']['core']['path']}/application/cli"
  command "php cli.php migrations:migrate --no-interaction"
  not_if { ::Dir.glob("#{node['jbx']['core']['path']}/application/migrations/*.php").empty? }
end
