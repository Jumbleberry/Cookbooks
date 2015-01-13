service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [ :stop ]
end

#Nginx package
ppa "nginx/stable"

# Update repository
execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
end

# Install latest nginx
package 'nginx' do
  action :upgrade
  options '--force-yes'
  options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
end

#Removes the default virtual host if exists
['default', 'default.dpkg-dist'].each do | file |
    if (File.file?('/etc/nginx/sites-enabled/' + file))
        link '/etc/nginx/sites-enabled/' + file do
          action :delete
        end
    end
    if (File.file?('/etc/nginx/sites-available/' + file))
        file '/etc/nginx/sites-available/' + file do
          action :delete
        end
    end
end

template '/etc/nginx/nginx.conf' do
  source    "nginx.conf.erb"
  variables ({
    "worker_processes" => node['nginx']['worker_processes'],
    "worker_connections" => node['nginx']['worker_connections']
  })
end

virtualhost         = '/etc/nginx/sites-available/default'
virtualhost_link    = '/etc/nginx/sites-enabled/default'

template virtualhost do
  source    "default.erb"
end

link virtualhost_link do
  to virtualhost
end

include_recipe "nginx::certs"