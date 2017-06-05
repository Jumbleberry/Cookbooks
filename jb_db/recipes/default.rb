# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

mysql_version = node[:lsb][:release].to_f > 16? '5.7': '5.6'

# Set mysql server default password
root_password = "root"
execute "mysql-default-password" do
    command "echo \"mysql-server-#{mysql_version} mysql-server/root_password password #{root_password}\" | debconf-set-selections"
    user 'root'
end
execute "mysql-default-password-again" do
    command "echo \"mysql-server-#{mysql_version} mysql-server/root_password_again password #{root_password}\" | debconf-set-selections"
    user 'root'
end

# Install mysql server
execute "mysql-install" do
    command "(export DEBIAN_FRONTEND=\"noninteractive\"; sudo -E apt-get install -y -q mysql-server-#{mysql_version})"
    user "root"
end

# Copy config file
cookbook_file "/etc/mysql/my.cnf" do
    source "mysql/my.cnf"
    owner "root"
    group "root"
    mode "0644"
end

service 'mysql' do
    case node['platform']
    when 'ubuntu'
      if node['lsb']['release'].to_f > 16
        provider Chef::Provider::Service::Systemd
      elsif node['lsb']['codename'] == 'trusty'
        provider Chef::Provider::Service::Upstart
      end
    end
    supports status: true, restart: true, reload: true
    action [:enable, :restart]
end

# Create jbx user
query = "GRANT ALL ON *.* TO \'jbx\'@\'%\' IDENTIFIED BY \'#{root_password}\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root -p#{root_password}"
end

# Create 'root'@'%'
query = "GRANT ALL ON *.* TO \'root\'@\'%\' IDENTIFIED BY \'#{root_password}\'"
execute 'createJbxUser' do
    command "echo \"#{query}\" | mysql -u root -p#{root_password}"
end

include_recipe "nginx"
include_recipe "php"

home = node['jb_db']['home']

directory home do
	owner 'www-data'
	group 'www-data'
	mode 00755
	recursive true
	action :create
end

# Download the selected PHPMyAdmin archive
remote_file "#{Chef::Config['file_cache_path']}/phpMyAdmin-#{node['jb_db']['version']}-all-languages.tar.gz" do
  owner user
  group group
  mode 00644
	retries 5
	retry_delay 2
  action :create
  source "#{node['jb_db']['mirror']}/#{node['jb_db']['version']}/phpMyAdmin-#{node['jb_db']['version']}-all-languages.tar.gz"
  checksum node['jb_db']['checksum']
end

bash 'extract-php-myadmin' do
	user user
	group group
	cwd home
	code <<-EOH
		rm -fr *
		tar xzf #{Chef::Config['file_cache_path']}/phpMyAdmin-#{node['jb_db']['version']}-all-languages.tar.gz
		mv phpMyAdmin-#{node['jb_db']['version']}-all-languages/* #{home}/
		rm -fr phpMyAdmin-#{node['jb_db']['version']}-all-languages
	EOH
	not_if { ::File.exists?("#{home}/RELEASE-DATE-#{node['jb_db']['version']}")}
end

# I don't know why phpmyadmin has so many different configs in so many different directories
cookbook_file "/var/www/phpmyadmin/config.inc.php" do
    source "phpmyadmin/var-config.inc.php"
    owner "www-data"
    group "www-data"
    mode "0644"
end

# Copy phpmyadmin table dump
cookbook_file "/tmp/create_tables.sql" do
    source "phpmyadmin/create_tables.sql"
    owner "root"
    group "root"
    mode "0644"
end

# Restore phpmyadmin tables
execute "phpmyadmin" do
    command "mysql -u root -p#{root_password} < /tmp/create_tables.sql"
end


# Create nginx config file
template "/etc/nginx/sites-available/phpmyadmin" do
  source  "nginx/phpmyadmin.erb"
end

link "/etc/nginx/sites-enabled/phpmyadmin" do
    to "/etc/nginx/sites-available/phpmyadmin"
    action :create
end

# Reload nginx
service "nginx" do
    supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
    action :reload
end

# Install awscli
include_recipe "awscli"
template "/home/#{node['user']}/.aws/config" do
    source "aws/config.erb"
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "private_key" => node['aws']['aws_secret_access_key']
    })
end

# Create credentials for root user
directory "/root/.aws" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
end
template "/root/.aws/config" do
    source "aws/config.erb"
    variables ({
        "access_id"   => node['aws']['aws_access_key_id'],
        "private_key" => node['aws']['aws_secret_access_key']
    })
end

# Install JB DB Importer
directory node['jbdb_importer']['source_directory'] do
    action :create
end

template "#{node['jbdb_importer']['source_directory']}/jbdb_import" do
    source "jbdb_import.erb"
    variables ({
        "username"  => "root",
        "password"  => root_password,
        "s3_bucket" => node['aws']['db_bucket']
    })
    mode "0755"
end

link "#{node['jbdb_importer']['bin_directory']}/jbdb_import" do
    to "#{node['jbdb_importer']['source_directory']}/jbdb_import"
end

# Create JBX
execute "restore-JBX-DB" do
    command "jbdb_import jbx --create"
    ignore_failure true
    not_if 'echo "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = \'jbx\'" |  mysql -uroot -p' + root_password + ' jbx 2> /dev/null | grep "SCHEMA_NAME"'
end

# Create Gearman
# execute "restore-gearman-DB" do
#     command "jbdb_import gearman --gearman"
#     ignore_failure true
# end
