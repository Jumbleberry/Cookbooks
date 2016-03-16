# Phalcon installation
include_recipe "web-server"

# Based on https://github.com/k-kinzal/chef-php-phalcon
path  = node['phalcon']['download_path']
build_path = path + "/" + node['phalcon']['build_path']

git path do
  repository node['phalcon']['git_url']
  reference node['phalcon']['git_ref']
  action :sync
end

# Modify install file
cookbook_file build_path + '/install' do
    source "install"
    mode "0755"
    action :create
end

execute  "phalcon-build" do
  cwd build_path
  user "root"
  command %{./install}

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
        link "#{conf_dirs_alias}/#{node['phalcon']['conf_file']}" do
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
