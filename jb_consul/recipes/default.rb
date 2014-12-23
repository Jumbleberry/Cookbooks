user = node['user']
path = "/home/#{user}/"
min_servers = node['consul']['bootstrap_expect']

#Check if there is any consul agent runing.
#If we have an instance with the consul tag on cluster mode, it means that the bootstraping process is done
instances_hash = get_instances_by_tag("consul", "cluster", path)
if instances_hash['Reservations'].count() > 0
    #Get the ip of the first instance with consul runing on it
    instance_ip = instances_hash['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['PrivateIpAddress']
    #Add the instance server ip to the join list of the consul recipe
    node.default['consul']['servers'] = [instance_ip]
else
    #If we have no instance with the consul tag, then look for the bootstrap agents
    #Check if there is any bootstraping consul agent
    instances_hash = get_instances_by_tag("consul", "bootstrap", path)

    if instances_hash['Reservations'].count() < min_servers
        #Mark this server to be started as bootstrap
        node.default['consul']['service_mode'] = 'cluster'
        #Add the runing bootstrap servers to the join list
        bootstrap_servers = []
        instances_hash['Reservations'].each do | reservation |
            bootstrap_servers.push(reservation['Instances'][0]['NetworkInterfaces'][0]['PrivateIpAddress'])
        end
        node.default['consul']['servers'] = bootstrap_servers
    end

    #Set tag depending on how many bootstrap server we are runing
    if instances_hash['Reservations'].count() == (min_server + 1)
        #Already reach the amount of bootstrap servers, bootstraping is done
        #so we change the tags from consul-bootstrap to consul
        instances_hash['Reservations'].each do | reservation |
            reservation['Instances'].each do | instance |
                update_tag(instance['InstanceId'], {'consul' => 'cluster'})
            end
        end
        #Set the tag to the current runing instance
        update_tag(node['ec2']['instance_id'], {'consul' => 'cluster'})
    else
        #We haven't reached the needed bootstrap servers so we set the tag mark the server as another bootstrap
        update_tag(node['ec2']['instance_id'], {'consul' => 'bootstrap'})
    end
end

# Get an instance array by that have the specified tag on them
def get_instances_by_tag(tag_name, tag_value, tmp_path)
    check_consul_bootstrap = "aws ec2 describe-instances --filters 'Name=tag:#{tag_name},Values=#{jb_value}' > consul.json"
    execute check_consul_bootstrap do
        cwd tmp_path
    end
    instances_file = File.read("#{tmp_path}consul.json")
    JSON.parse(instances_file)
end

def update_tag(instance_id, tag)
    aws_resource_tag instance_id do
      aws_access_key node['aws']['aws_access_key_id']
      aws_secret_access_key node['aws']['aws_secret_access_key']
      tags(
          tag
      )
      action :add
    end
end
