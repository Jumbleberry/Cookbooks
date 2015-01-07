include_recipe 'datadog::dd-agent'

# Create yaml files
yamlTemplates = {
  'gearmand.yaml.erb' => 'gearmand',
  'mysql.yaml.erb'    => 'mysql',
  'nginx.yaml.erb'    => 'nginx',
  'redisdb.yaml.erb'  => 'redisdb'
}

yamlTemplates.each do | origin, dest |
  template node['datadog']['templateDir'] + "/#{dest}.yaml" do
    owner 'dd-agent'
    mode 00600    
  end
end

# Restart service
service 'datadog-agent' do
  action :restart
end