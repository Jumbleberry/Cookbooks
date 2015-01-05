default[:dnsmasq][:enable_dhcp] = false
default[:dnsmasq][:dhcp] = {}
default[:dnsmasq][:dhcp_options] = []
default[:dnsmasq][:enable_dns] = true
default[:dnsmasq][:dns] = {
  'server' => '127.0.0.1'
}
default[:dnsmasq][:dns_options] = []
default[:dnsmasq][:managed_hosts] = {}
default[:dnsmasq][:managed_hosts_bag] = "managed_hosts"
default[:dnsmasq][:user] = 'dnsmasq'

