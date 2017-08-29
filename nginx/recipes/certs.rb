include_recipe "aws_deploy"

# Creates gpg directory
directory '/etc/nginx/ssl' do
    owner "www-data"
    group "www-data"
end

gpg = node.attribute?('aws_deploy_key')? '.gpg' : ''

node['nginx']['certs'].each do | cert |
    [ "key", "pem" ].each do | ext |

        #Move encrypted key file to destination folder
        cookbook_file "/etc/nginx/ssl/#{cert}.#{ext}#{gpg}" do
            source "ssl/#{cert}.#{ext}#{gpg}"
            owner "root"
            group "root"
            mode "0664"
            ignore_failure true
            notifies :reload, 'service[nginx]', :delayed
        end
    
        if node.attribute?('aws_deploy_key')
            #Unencrypt key using the previosuly imported gpg key
            execute "unencrypt key: #{cert}.#{ext}" do
                cwd '/etc/nginx/ssl/'
                command "gpg --output #{cert}.#{ext} --decrypt --batch --yes #{cert}.#{ext}.gpg && chmod 0600 #{cert}.#{ext}"
                not_if { File.size?("/etc/nginx/ssl/#{cert}.#{ext}#{gpg}").nil? || File.size?("/etc/nginx/ssl/#{cert}.#{ext}#{gpg}") == 0 }
                user "root"
            end
        end
    end
end