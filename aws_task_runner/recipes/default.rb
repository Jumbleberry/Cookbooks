# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

# Install default jre
apt_package 'default-jre' do
    action :install
end

# Create task runner home directory
directory node['task_runner']['home_directory'] do
    owner 'ubuntu'
    group 'ubuntu'
    mode '0755'
    action :create
end

# Copy TaskRunner-1.0.jar and mysql-conector-java-bin.jar
remote_file "#{node['task_runner']['home_directory']}/TaskRunner-1.0.jar" do
    source node['task_runner']['task_runner_jar']
    owner 'ubuntu'
    group 'ubuntu'
    mode '0664'
    action :create
end
remote_file "#{node['task_runner']['home_directory']}/mysql-connector-java-bin.jar" do
    source node['task_runner']['mysql_connector_jar']
    owner 'ubuntu'
    group 'ubuntu'
    mode '0664'
    action :create
end

# Create credentials.json
template "#{node['task_runner']['home_directory']}/credentials.json" do
    source    "credentials.json.erb"
    owner 'ubuntu'
    group 'ubuntu'
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "private_key" => node['aws']['aws_secret_access_key'],
    })
end

# Copy daemon
cookbook_file "/etc/init.d/taskrunner" do
    source "taskrunner"
    owner "root"
    group "root"
    mode "0755"
end

# Create daemon
execute "create-taskrunner-daemon" do
    command "update-rc.d taskrunner defaults"
    user 'root'
end

# Start daemon
service 'taskrunner' do
    action :start
end
