# Phalcon installation
include_recipe "web-server"
include_recipe "apt"

# Installs php package and modules
phpmodules = node['phalcon']['packages']
phpmodules.each do |pkg|
  package "#{pkg['name']}" do
    action :install
    version pkg["version"]
    # Ignore configuration changes - necessary because of nginx updates
    options '--force-yes'
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
  end
end

# Install zephir
git node['zephir']['download_path'] do
  repository node['zephir']['git_url']
  reference node['zephir']['git_ref']
  action :sync
end

execute "zephir-install" do 
    user "root"
    cwd node['zephir']['download_path']
    command "./install -c"
end

# Install phalcon
git node['phalcon']['download_path'] do
  repository node['phalcon']['git_url']
  reference node['phalcon']['git_ref']
  action :sync
end

execute  "phalcon-build" do
  cwd node['phalcon']['download_path']
  user "root"
  command "zephir build -backend=ZendEngine3"

  node['phalcon']['conf_dirs'].each do |conf_dir|
      not_if do
          ::File.exists?("#{conf_dir}/#{node['phalcon']['conf_file']}")
      end
  end
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
        link "#{conf_dirs_alias}/30-#{node['phalcon']['conf_file']}" do
          to "#{conf_dir}/#{node['phalcon']['conf_file']}"
          notifies :restart, "service[php7.0-fpm]", :immediately
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
