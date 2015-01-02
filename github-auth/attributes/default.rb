user = 'root'
home = node['etc']['passwd'][user]['dir']

default['github']['wrapper_path'] = "#{home}/.ssh"
