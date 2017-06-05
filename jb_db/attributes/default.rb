default['jb_db']['version'] = '4.7.1'
default['jb_db']['checksum'] = 'de1f4a9c1f917ae63b07be4928d9b9dba7f29c51b1e1be3ed351d1bc278a8b28'
default['jb_db']['mirror'] = 'https://files.phpmyadmin.net/phpMyAdmin/'
default['jb_db']['home'] = '/var/www/phpmyadmin'

default['jbdb_importer']['source_directory'] = '/etc/jbdb_importer'
default['jbdb_importer']['bin_directory']    = '/usr/bin'

default['mysql']['server_root_user']     = 'root'

default['aws']['db_bucket'] = 's3://miscfile-staging/db-backups'
default[:aws][:compile_time] = false