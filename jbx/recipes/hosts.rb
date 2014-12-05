# Add custom domains
template '/etc/hosts' do
  source 'hosts.erb'
  variables ({
        'hostname'              => "#{node['fqdn']} #{node['hostname']}",
        'mysql_read_host_1'     => node['jbx']['credentials']['mysql_read']['host'],
        'mysql_read_host_2'     => node['jbx']['credentials']['mysql_read']['host'],
        'mysql_write_host_1'    => node['jbx']['credentials']['mysql_write']['host'],
        'mysql_write_host_2'    => node['jbx']['credentials']['mysql_write']['host'],
        'redis_host_read_1'     => node['jbx']['credentials']['redis']['host'],
        'redis_host_read_2'     => node['jbx']['credentials']['redis']['host'],
        'redis_host_write_1'    => node['jbx']['credentials']['redis']['host'],
        'redis_host_write_2'    => node['jbx']['credentials']['redis']['host'],
        'gearman_host_1'        => node['jbx']['credentials']['gearman']['host'],
        'gearman_host_2'        => node['jbx']['credentials']['gearman']['host']
  })
  mode 0644
  owner 'root'
  group 'root'
end
