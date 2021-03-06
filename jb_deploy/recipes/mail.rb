include_recipe "jb_deploy::core"

# Set the branch to checkout
branch = ENV['JBX_MAIL_BRANCH'] || node['jbx']['mail']['branch']

{ :checkout => true, :sync => node[:user] != 'vagrant' }.each do |action, should|
    git node['jbx']['mail']['path'] do
      ssh_wrapper node['github-auth']['wrapper_path'] + "/mail_wrapper.sh"
      repository node['jbx']['mail']['git-url']
      revision branch
      user 'root'
      action action
      only_if { should }
    end
end

execute "chown-data-www" do
  command "chown -R #{node['jbx']['user']}:#{node['jbx']['user']} #{node['jbx']['mail']['path']}"
  user "root"
  action :run
end
