#
# Cookbook:: elastic_repo_test
# Recipe:: v6
#

version = '6.3.0'

elastic_repo_options = {
  'version' => version,
  'description' => 'Elastic Packages Repository Custom',
  'gpg_key' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
  'yum_baseurl' => 'https://artifacts.elastic.co/packages/6.x/yum',
  'yum_gpgcheck' => true,
  'yum_enabled' => true,
  'yum_priority' => '20',
  'yum_metadata_expire' => '1h',
  'apt_uri' => nil,
  'apt_components' => %w[stable main],
  'apt_distribution' => ''
}

elastic_repo 'default' do
  version elastic_repo_options['version']
  action :delete
end

elastic_repo 'default' do
  elastic_repo_options.each do |key, value|
    send(key, value) unless value.nil?
  end
end

package %w[apt-utils openjdk-8-jdk] if node['platform_family'] == 'debian'
package_version = %w[fedora rhel amazon].include?(node['platform_family']) ? "#{version}-1" : version

%w[filebeat packetbeat metricbeat heartbeat-elastic auditbeat elasticsearch kibana].each do |p|
  package p do
    version package_version
  end
end
