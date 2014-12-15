#Configurations
path = "/tmp/s3fs-fuse/"
mnt_path = "/mnt/s3"
password_file = "/etc/passwd-s3fs"
dependencies = ["build-essential", "git", "libfuse-dev", "libcurl4-openssl-dev", "libxml2-dev", "mime-support", "automake", "libtool"]

#Install library dependencies
dependencies.each do |pkg|
    package "#{pkg}" do
        action :install
    end
end

#Clone library
git path do
    repository "https://github.com/s3fs-fuse/s3fs-fuse.git"
    action :sync
end

#Moves installation script to cloned repo
cookbook_file "#{path}install_s3fs.sh" do
    source "install_s3fs.sh"
    owner "www-data"
    group "www-data"
    mode 0777
end

#Execute installation script
execute  "s3fs-fuse-installation" do
    cwd "#{path}"
    user "www-data"
    command "./install_s3fs.sh"
    not_if { ::File.exists?(password_file)}
end

#Adds password file
file "s3fs-fuse-password" do
    path password_file
    content node['s3fs-fuse']['password']
    owner "www-data"
    group "www-data"
    mode 0640
end

#Creates mount folder
directory mnt_path do
    action :create
    owner "www-data"
    group "www-data"
end

#Adds new mnt path to fstab for automount
ruby_block "adds to fstab" do
    block do
        fstab = Chef::Util::FileEdit.new("/etc/fstab")
        fstab.insert_line_if_no_match("/s3fs/", "s3fs#jbdocstorage #{mnt_path} fuse    allow_other,_netdev,use_cache=/tmp 0 0")
        fstab.write_file
    end
    not_if "grep -q s3fs /etc/fstab"
end

#Mount the new partition
execute "mount s3fs partition" do
    user "www-data"
    command "s3fs jbdocstorage /mnt/s3 -ouse_cache=/tmp -o allow_other"
    not_if "df | grep -q s3fs"
end
