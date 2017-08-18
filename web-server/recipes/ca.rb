# Creates gpg directory
directory '/usr/local/share/ca-certificates/' do
    owner "root"
    group "root"
end

for cert in ['rootCA.crt', 'betwixtCA.crt']
    if node.attribute?('aws_deploy_key')
        include_recipe "aws_deploy"
        
        #Move encrypted key file to destination folder
        cookbook_file "/tmp/#{cert}.gpg" do
            source "#{cert}.gpg"
            owner "root"
            group "root"
            mode "0664"
            notifies :run, "execute[#{cert}]", :immediately
        end
        
        #Unencrypt key using the previosuly imported gpg key
        execute "#{cert}" do
            cwd '/tmp/'
            command "gpg --output /usr/local/share/ca-certificates/#{cert} --decrypt --batch --yes #{cert}.gpg && chmod 0664 /usr/local/share/ca-certificates/#{cert}"
            user "root"
            action :nothing
            not_if { File.size?("/tmp/#{cert}.gpg").nil? || File.size?("/tmp/#{cert}.gpg") == 0 }
            notifies :run, "ruby_block[insert_line]", :immediately
        end
    else
        #Move encrypted key file to destination folder
        cookbook_file "/usr/local/share/ca-certificates/#{cert}" do
            source "#{cert}"
            owner "root"
            group "root"
            mode "0664"
            not_if { File.exists?("/usr/local/share/ca-certificates/#{cert}") }
            notifies :run, "ruby_block[insert_line]", :immediately
        end
    end
    
    ruby_block "insert_line" do
      block do
        file = Chef::Util::FileEdit.new("/etc/ca-certificates.conf")
        file.insert_line_if_no_match(/#{cert}/, "#{cert}")
        file.write_file
      end
      action :nothing
      notifies :run, "execute[sudo update-ca-certificates]", :immediately
    end
end

execute 'sudo update-ca-certificates' do
    user "root"
    action :nothing
end