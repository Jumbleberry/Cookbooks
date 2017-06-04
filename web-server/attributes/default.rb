interfaces  = node.key(:network_interface)? [node[:network_interface]]: []
interfaces += ['eth1', 'eth0', 'enp0s8', 'ens3']

interfaces.each do |interface|
    if node[:network][:interfaces].key?(interface)
        override![:network_interface] = interface
    end
end