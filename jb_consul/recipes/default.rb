user = node['user']
stack_file = node['jb_consul']['stack_file_path'] + node['jb_consul']['stack_file']
min_servers = node['consul']['bootstrap_expect'].to_i

#Check if there is any consul agent runing.
#If we have an instance with the consul tag on cluster mode, it means that the bootstraping process is done
if node.attribute?('ec2')
    check_consul_bootstrap = "aws ec2 describe-instances --filters 'Name=tag:consul,Values=cluster' > #{stack_file}"
    execute check_consul_bootstrap
end
instances_hash = JSON.parse(File.read("#{stack_file}"))
if instances_hash['Reservations'].count() > 0
    #Get the ip of the first instance with consul runing on it
    instance_ip = instances_hash['Reservations'][0]['Instances'][0]['PrivateIpAddress']
    #Add the instance server ip to the join list of the consul recipe
    node.override['consul']['servers'] = [instance_ip]
    node.override['consul']['service_mode'] = 'client'
else
    #If we have no instance with the consul tag, then look for the bootstrap agents
    #Check if there is any bootstraping consul agent
    if node.attribute?('ec2')
        check_consul_bootstrap = "aws ec2 describe-instances --filters 'Name=tag:consul,Values=bootstrap' > #{stack_file}"
        execute check_consul_bootstrap
    end
    instances_hash = JSON.parse(File.read("#{stack_file}"))

    if instances_hash['Reservations'].count() < min_servers
        #Mark this server to be started as bootstrap
        node.override['consul']['service_mode'] = 'cluster'
        #Add the runing bootstrap servers to the join list
        bootstrap_servers = []
        instances_hash['Reservations'].each do | reservation |
            bootstrap_servers.push(reservation['Instances'][0]['PrivateIpAddress'])
        end
        node.override['consul']['servers'] = bootstrap_servers
    end

    if node.attribute?("ec2")
        #Set tag depending on how many bootstrap server we are runing
        if instances_hash['Reservations'].count() == (min_servers - 1)
            #Already reach the amount of bootstrap servers, bootstraping is done
            #so we change the tags from consul-bootstrap to consul
            instances_hash['Reservations'].each do | reservation |
                reservation['Instances'].each do | instance |
                    aws_resource_tag instance['InstanceId'] do
                        aws_access_key node['aws']['aws_access_key_id']
                        aws_secret_access_key node['aws']['aws_secret_access_key']
                        tags (
                            {'consul' => 'cluster'}
                        )
                        action :add
                    end
                end
            end
            #Set the tag to the current runing instance
            aws_resource_tag node['ec2']['instance_id'] do
                aws_access_key node['aws']['aws_access_key_id']
                aws_secret_access_key node['aws']['aws_secret_access_key']
                tags (
                    {'consul' => 'cluster'}
                )
                action :add
            end
        else
            #We haven't reached the needed bootstrap servers so we set the tag mark the server as another bootstrap
            aws_resource_tag node['ec2']['instance_id'] do
                aws_access_key node['aws']['aws_access_key_id']
                aws_secret_access_key node['aws']['aws_secret_access_key']
                tags (
                    {'consul' => 'bootstrap'}
                )
                action :add
            end
        end
    end
end
