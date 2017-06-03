include_recipe "datadog::dd-agent"
include_recipe "datadog::dd-handler"

# Create yaml files
node['datadog']['services'].each do | service, instances |
  template node['datadog']['template_dir'] + "/#{service}.yaml" do
    source "#{service}.yaml.erb"
    owner 'dd-agent'
    mode 00644
    variables ({
        "ipAddress" => (
                node[:network][:interfaces][node[:network_interface]] || 
                node[:network][:interfaces][:enp0s8] ||
                node[:network][:interfaces][:ens3]
            )[:addresses].detect{|k,v| v[:family] == "inet" }.first
    })
  end
end

# Restart service
service 'datadog-agent' do
  action :restart
end