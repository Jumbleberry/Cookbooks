default['admin']['hostname']                = 'admin.jumbleberry.com'
default['admin']['path']                    = '/var/www/admin/'
default['admin']['git-url']                 = 'git@github.com:Jumbleberry/admin.git'
default['admin']['branch']                  = 'master'
default['admin']['github_key']              = ''
default['admin']['environment']             = ''

default['admin']['storage']['base']         = '/mnt'
default['admin']['storage']['bank']         = '/s3/bank/'
default['admin']['storage']['user_images']  = '/s3/images/user/'

default['admin']['jbxroute']                = 'http://jbxroute.com'
default['admin']['jbxtrack']                = 'https://jbxtrack.com'

default["gearman"]["retries"]           = "3"
default["gearman"]["ip"]                = "0.0.0.0"
default['gearman']['mysql']['host']     = ""
default['gearman']['mysql']['user']     = ""
default['gearman']['mysql']['password'] = ""
default['gearman']['mysql']['db']       = ""
default['gearman']['mysql']['table']    = ""
default['gearman']['mysql']['port']     = "3306"