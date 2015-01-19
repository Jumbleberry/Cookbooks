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
default['admin']['key_salt']                = ''
default['admin']['key_pass']                = ''

default['admin']['display_startup_errors']  = 0
default['admin']['php_display_errors']      = 0
default['admin']['display_exceptions']      = 0

default['admin']['redirect']['hosts']       = ''
default['admin']['redirect']['username']    = ''
default['admin']['redirect']['password']    = ''
default['admin']['redirect']['dbname']      = ''

default['admin']['mail']['host']         = ''
default['admin']['mail']['username']       = ''
default['admin']['mail']['password']       = ''
default['admin']['mail']['auth']           = ''
default['admin']['mail']['port']           = ''

default['admin']['mysql_write']['host']     = ''
default['admin']['mysql_write']['username'] = ''
default['admin']['mysql_write']['password'] = ''
default['admin']['mysql_write']['dbname']   = ''
default['admin']['mysql_write']['default']  = ''

default['admin']['mysql_read']['host']      = ''
default['admin']['mysql_read']['username']  = ''
default['admin']['mysql_read']['password']  = ''
default['admin']['mysql_read']['dbname']    = ''
default['admin']['mysql_read']['default']   = ''

default['admin']['hitpath_read']['host']         = ''
default['admin']['hitpath_read']['username']     = ''
default['admin']['hitpath_read']['password']     = ''
default['admin']['hitpath_read']['dbname']       = ''
default['admin']['hitpath_read']['default']      = ''