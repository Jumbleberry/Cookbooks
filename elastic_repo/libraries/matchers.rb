if defined?(ChefSpec)
  ChefSpec.define_matcher(:elasticsearch_configure)

  def create_elastic_repo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:elastic_repo, :create, resource_name)
  end

  def delete_elastic_repo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:elastic_repo, :delete, resource_name)
  end
end
