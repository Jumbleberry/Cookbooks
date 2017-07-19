# Creates gpg directory
directory '/usr/local/share/ca-certificates/' do
    owner "root"
    group "root"
end

if node.attribute?('aws_deploy_key')
    include_recipe "aws_deploy"
    
    #Move encrypted key file to destination folder
    cookbook_file "/tmp/rootCA.crt.gpg" do
        source "rootCA.crt.gpg"
        owner "root"
        group "root"
        mode "0664"
        notifies :run, "execute[rootCA.crt]", :immediately
    end
    
    #Unencrypt key using the previosuly imported gpg key
    execute "rootCA.crt" do
        cwd '/tmp/'
        command "gpg --output /usr/local/share/ca-certificates/rootCA.crt --decrypt --batch --yes rootCA.crt.gpg && chmod 0664 /usr/local/share/ca-certificates/rootCA.crt"
        user "root"
        action :nothing
        not_if { File.size?("/tmp/rootCA.crt.gpg").nil? || File.size?("/tmp/rootCA.crt.gpg") == 0 }
        notifies :run, "ruby_block[insert_line]", :immediately
    end
else
    #Move encrypted key file to destination folder
    cookbook_file "/usr/local/share/ca-certificates/rootCA.crt" do
        source "rootCA.crt"
        owner "root"
        group "root"
        mode "0664"
        not_if { File.exists?("/usr/local/share/ca-certificates/rootCA.crt") }
        notifies :run, "ruby_block[insert_line]", :immediately
    end
end

ruby_block "insert_line" do
  block do
    file = Chef::Util::FileEdit.new("/etc/ca-certificates.conf")
    file.insert_line_if_no_match(/rootCA.crt/, "rootCA.crt")
    file.write_file
  end
  action :nothing
  notifies :run, "execute[sudo update-ca-certificates]", :immediately
end

execute 'sudo update-ca-certificates' do
    user "root"
    action :nothing
end