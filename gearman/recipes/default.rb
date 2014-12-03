#Gearman package
package 'gearman' do
  action :install
  version node["gearman"]["version"]
end

#Gearman service
service 'gearman-job-server' do
  action :nothing
end
