# # encoding: utf-8

# Inspec test for cookbook elastic_repo lwrp resource

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

if %w[redhat fedora amazon].include?(os[:family])
  describe file('/etc/yum.repos.d/elastic6.repo') do
    its('content') { should match %r{https://artifacts.elastic.co/packages/6.x/yum} }
  end
else
  describe file('/etc/apt/sources.list.d/elastic6.list') do
    its('content') { should match %r{https://artifacts.elastic.co/packages/6.x/apt} }
  end
end

describe package('filebeat') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('packetbeat') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('metricbeat') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('heartbeat-elastic') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('auditbeat') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('elasticsearch') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end

describe package('kibana') do
  it { should be_installed }
  its('version') { should match '6.3.0' }
end
