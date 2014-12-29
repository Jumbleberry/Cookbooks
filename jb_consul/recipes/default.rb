user = node['user']
min_servers = node['consul']['bootstrap_expect'].to_i

#Check if there is any consul agent runing.
#If we have an instance with the consul tag on cluster mode, it means that the bootstraping process is done
fetch_instances_by_tag 'consul' do
    tag_value 'cluster'
end
instances_hash = node['jb_consul']['instances']['cluster']
if instances_hash['Reservations'].count() > 0
    #Get the ip of the first instance with consul runing on it
    instance_ip = instances_hash['Reservations'][0]['Instances'][0]['PrivateIpAddress']
    #Add the instance server ip to the join list of the consul recipe
    node.override['consul']['servers'] = [instance_ip]
    node.override['consul']['service_mode'] = 'client'
else
    #If we have no instance with the consul tag, then look for the bootstrap agents
    #Check if there is any bootstraping consul agent
    fetch_instances_by_tag 'consul' do
        tag_value 'bootstrap'
    end
    instances_hash = node['jb_consul']['instances']['bootstrap']

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

#    if node.has_key?("ec2")
        #Set tag depending on how many bootstrap server we are runing
        if instances_hash['Reservations'].count() == (min_servers - 1)
            #Already reach the amount of bootstrap servers, bootstraping is done
            #so we change the tags from consul-bootstrap to consul
            instances_hash['Reservations'].each do | reservation |
                reservation['Instances'].each do | instance |
                    update_tag instance['InstanceId'] do
                        tag_name 'consul'
                        tag_value 'cluster'
                    end
                end
            end
            #Set the tag to the current runing instance
            update_tag node['ec2']['instance_id'] do
                tag_name 'consul'
                tag_value 'cluster'
            end
        else
            #We haven't reached the needed bootstrap servers so we set the tag mark the server as another bootstrap
            update_tag node['ec2']['instance_id'] do
                tag_name 'consul'
                tag_value 'bootstrap'
            end
        end
#    end
end
