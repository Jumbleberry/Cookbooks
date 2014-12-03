# Phantomjs dependencies
package "libfontconfig" do
  action :install
end

# Phantomjs Install
phantomjs  = "#{Chef::Config['file_cache_path']}/phantomjs.tar.bz2"
phantomjs_install_path = '/opt/phantomjs'

remote_file phantomjs do
  source node['casperjs']['phantomjs_url']
end

execute 'extract_phantomjs' do
  command "mkdir /opt/phantomjs; tar jxf #{phantomjs} -C #{phantomjs_install_path} --strip-components=1"
  not_if { ::File.exists?("#{phantomjs_install_path}/bin/phantomjs")}
end

link '/usr/local/bin/phantomjs' do
  to "#{phantomjs_install_path}/bin/phantomjs"
end

# Casperjs install
casper_path = '/opt/casperjs'
link_casper_path = '/usr/local/bin/casperjs'

git casper_path do
  repository node['casperjs']['git_url']
  reference node['casperjs']['git_ref']
  action :sync
end

link link_casper_path do
  to "#{casper_path}/bin/casperjs"
end
