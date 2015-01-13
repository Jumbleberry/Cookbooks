user = 'root'
home = node['etc']['passwd'][user]['dir']

default['github-auth']['wrapper_path']  = "#{home}/.ssh"
default['github-auth']['keys']          = []
