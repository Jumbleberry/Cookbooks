#
# Cookbook Name:: s3fs-fuse
# Recipe:: default
#

mounted_directories = node[:s3fs_fuse][:mounts]
if(mounted_directories.is_a?(Hash) || !mounted_directories.respond_to?(:each))
  mounted_directories = [node[:s3fs_fuse][:mounts]].compact
end

include_recipe "s3fs-fuse::install"

if(node[:s3fs_fuse][:bluepill])
  include_recipe 's3fs-fuse::bluepill'
elsif(node[:s3fs_fuse][:rc_mon])
  include_recipe 's3fs-fuse::rc_mon'
else
  mounted_directories.each do |dir_info|
    
    #unmount a drive
    mount dir_info[:path] do
      device "s3fs##{dir_info[:bucket]}"
      fstype 'fuse'
      action [:umount, :disable]
    end
    
    # Force unmount - don't care if it works
    execute "umount #{dir_info[:path]} || true"
    
    dir = dir_info[:tmp_store] || '/tmp/s3_cache' 
    
    # delete the cache
    directory dir do
        recursive true
        action :delete
    end
    
    # Delete the mount dir
    directory dir_info[:path] do
        recursive true
        action :delete
        only_if { Dir[dir_info[:path] + '/*'].empty? }
    end
    
    # Create the mount dir
    directory dir_info[:path] do
        recursive true
        action :create
        not_if { File.directory? dir_info[:path] }
    end
    
    # Mount the drive
    mount dir_info[:path] do
      device "s3fs##{dir_info[:bucket]}"
      fstype 'fuse'
      dump 0
      pass 0
      options "allow_other,url=#{node[:s3fs_fuse][:s3_url]},stat_cache_expire=300,passwd_file=/etc/passwd-s3fs,use_cache=#{dir_info[:tmp_store] || '/tmp/s3_cache'},retries=20#{",noupload" if dir_info[:no_upload]},#{dir_info[:read_only] ? 'ro' : 'rw'}"
      action [:mount, :enable]
    end
  end
end
