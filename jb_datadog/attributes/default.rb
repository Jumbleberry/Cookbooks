# Override the default datadog name
override['datadog']['hostname'] =  node['hostname'] + '.' + node['role'] + '.' + node['environment']