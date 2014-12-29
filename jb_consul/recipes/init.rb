#Check if there is any consul agent runing.
#If we have an instance with the consul tag on cluster mode, it means that the bootstraping process is done
fetch_instances_by_tag 'consul' do
    tag_value 'cluster'
end

#If we have no instance with the consul tag, then look for the bootstrap agents
# Check if there is any bootstraping consul agent
fetch_instances_by_tag 'consul' do
    tag_value 'bootstrap'
end