execute "update apt" do
  command "apt-get update --fix-missing"
  user "root"
end

package 'dnsmasq'

service 'dnsmasq' do
  action [:enable, :start]
end

if(node[:dnsmasq][:enable_dns])
  include_recipe 'dnsmasq::dns'
end

if(node[:dnsmasq][:enable_dhcp])
  include_recipe 'dnsmasq::dhcp'
end
