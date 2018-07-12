#
# Cookbook Name:: elastic_repo
# Resource:: elastic_repo
#
# Copyright 2017, Virender Khatri
#

resource_name :elastic_repo

property :version, String, default: '6.3.0'
property :description, String, default: 'Elastic Packages Repository'
property :gpg_key, String, default: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

property :apt_uri, [String, NilClass], default: nil
property :apt_components, Array, default: %w[stable main]
property :apt_distribution, String, default: ''

property :yum_baseurl, [String, NilClass], default: nil
property :yum_gpgcheck, [TrueClass, FalseClass], default: true
property :yum_enabled, [TrueClass, FalseClass], default: true
property :yum_priority, [String, NilClass], default: %w[amazon].include?(node['platform_family']) ? '10' : nil
property :yum_metadata_expire, String, default: '3h'

default_action :create

action :create do
  major_version = new_resource.version.split('.')[0]
  repo_name = "elastic#{major_version}"
  apt_uri = new_resource.apt_uri ? new_resource.apt_uri : "https://artifacts.elastic.co/packages/#{major_version}.x/apt"
  yum_baseurl = new_resource.yum_baseurl ? new_resource.yum_baseurl : "https://artifacts.elastic.co/packages/#{major_version}.x/yum"

  if node['platform_family'] == 'debian'
    package 'apt-transport-https'

    apt_repository repo_name do
      uri apt_uri
      key new_resource.gpg_key
      components new_resource.apt_components
      distribution new_resource.apt_distribution
    end

  elsif %w[amazon rhel fedora].include?(node['platform_family'])
    yum_repository repo_name do
      baseurl yum_baseurl
      gpgkey new_resource.gpg_key
      gpgcheck new_resource.yum_gpgcheck
      description new_resource.description
      enabled new_resource.yum_enabled
      metadata_expire new_resource.yum_metadata_expire
      priority new_resource.yum_priority if new_resource.yum_priority
    end

  else
    raise "platform_family #{node['platform_family']} is not supported"
  end
end

action :delete do
  major_version = new_resource.version.split('.')[0]
  repo_name = "elastic#{major_version}"

  if node['platform_family'] == 'debian'
    apt_repository repo_name do
      action :remove
    end

  elsif %w[amazon rhel fedora].include?(node['platform_family'])
    yum_repository repo_name do
      action :remove
    end
  end
end
