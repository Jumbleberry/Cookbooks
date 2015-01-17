# Override the default datadog name
node.override['datadog']['hostname'] =  node.name + '.' + default['role'] + '.' + default['environment']

include_recipe "datadog::dd-handler"
include_recipe "datadog::dd-agent"

# Create yaml files
node['datadog']['services'].each do | service, instances |
  template node['datadog']['template_dir'] + "/#{service}.yaml" do
    source "#{service}.yaml.erb"
    owner 'dd-agent'
    mode 00644
    variables ({
        "ipAddress" => node[:network][:interfaces][node[:network_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
    })
  end
end

# Restart service
service 'datadog-agent' do
  action :restart
end