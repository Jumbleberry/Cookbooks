# Phalcon installation
include_recipe "web-server"
include_recipe "php"
include_recipe "apt"

service 'php7.1-fpm' do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
  ignore_failure true
end

execute "install phalcon" do
    cwd "/tmp"
    command "curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash"
    notifies :install, "package[php7.1-phalcon]", :immediately
end

package "php7.1-phalcon" do
    action :nothing
    # Ignore configuration changes - necessary because of nginx updates
    options '--force-yes'
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    version '3.2.2-1+php7.1'
end

# Creates symlinks for the configurations files
node['phalcon']['conf_dirs'].each do |conf_dir|
    cookbook_file "#{conf_dir}/#{node['phalcon']['conf_file']}" do
        source "phalcon.ini"
        owner "root"
        group "root"
        mode 0644
    end
    
    node['phalcon']['conf_dirs_alias'].each do |conf_dirs_alias|
        file "#{conf_dirs_alias}/20-#{node['phalcon']['conf_file']}" do
          action :delete
          force_unlink true
          only_if { File.exist? "#{conf_dirs_alias}/20-#{node['phalcon']['conf_file']}" }
        end
    
        link "#{conf_dirs_alias}/50-#{node['phalcon']['conf_file']}" do
          to "#{conf_dir}/#{node['phalcon']['conf_file']}"
          notifies :restart, "service[php7.1-fpm]", :delayed
        end
    end
end

if node['phalcon']['devtools']
    bash "phalcon-devtools" do
        user "root"
        cwd "/usr/share"
        code <<-EOH
            git clone https://github.com/phalcon/phalcon-devtools.git
            cd phalcon-devtools
            . ./phalcon.sh
      ln -s /usr/share/phalcon-devtools/phalcon.php /usr/bin/phalcon
        EOH
        not_if { ::File.exists?("/usr/share/phalcon-devtools/phalcon.php")}
    end
end
