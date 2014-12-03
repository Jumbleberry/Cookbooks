default['mariadb']['ppa']['url'] = 'http://mariadb.mirror.rafal.ca/repo/10.0/ubuntu'
default['mariadb']['ppa']['distribution'] = 'precise'
default['mariadb']['ppa']['components'] = ['main']
default['mariadb']['ppa']['keyserver'] = 'hkp://keyserver.ubuntu.com:80'
default['mariadb']['ppa']['key'] = '0xcbcb082a1bb943db'

default['mariadb']['version'] = '10.0.*'

default['mariadb']['myconf']['bind-address'] = '127.0.0.1'

default['mariadb']['remote']['user'] = 'root'
default['mariadb']['remote']['host'] = '192.168.55.%'
