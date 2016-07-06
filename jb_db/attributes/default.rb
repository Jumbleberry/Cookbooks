default['jbdb_importer']['source_directory'] = '/etc/jbdb_importer'
default['jbdb_importer']['bin_directory']    = '/usr/bin'

default['mysql']['server_root_user']     = 'root'

default['aws']['db_bucket'] = 's3://miscfile-staging/db-backups'
default[:aws][:compile_time] = false