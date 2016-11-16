default['phpHost']                              = 'localhost:9000';
default['nginx_swarm']['worker_processes']      = 4
default['nginx_swarm']['worker_connections']    = 2048
default['nginx_swarm']['certs']                 = []
default['nginx_swarm']['deps']                  = ['build-essential', 'zlib1g-dev', 'libpcre3', 'libpcre3-dev', 'unzip']