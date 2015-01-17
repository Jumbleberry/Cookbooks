# Override the default datadog name
override['datadog']['hostname'] =  node.name + '.' + node['role'] + '.' + node['environment']