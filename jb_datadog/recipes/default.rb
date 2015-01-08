include_recipe 'datadog::dd-agent'

# Create yaml files
node['datadog']['services'].each do | service, instances |
  template node['datadog']['templateDir'] + "/#{service}.yaml" do
    source "#{service}.yaml.erb"
    owner 'dd-agent'
    mode 00644
  end
end

# Restart service
service 'datadog-agent' do
  action :restart
end