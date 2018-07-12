elastic_repo Cookbook
================

[![Cookbook](https://img.shields.io/github/tag/vkhatri/chef-elastic-repo.svg)](https://github.com/vkhatri/chef-elastic-repo) [![Build Status](https://travis-ci.org/vkhatri/chef-elastic-repo.svg?branch=master)](https://travis-ci.org/vkhatri/chef-elastic-repo)

This is a [Chef] Cookbook to Create Yum/Apt [Elastic] Repository.


>> For Production environment, always prefer the [most recent release](https://supermarket.chef.io/cookbooks/elastic_repo).


## Most Recent Release

```ruby
cookbook 'elastic_repo', '~> 1.1.1'
```


## From Git

```ruby
cookbook 'elastic_repo', github: 'vkhatri/chef-elastic-repo',  tag: 'v1.1.1'
```


## Repository

```
https://github.com/vkhatri/chef-elastic-repo
```


## Supported Elasticsearch Versions

- 5
- 6


## Resource elastic_repo Properties

Resource `elastic_repo` setup `apt` and `yum` Elastic Repository.

Usage:
```ruby
elastic_repo 'default'
```

* `version (String)` default: '6.3.0'

* `description (String)` default: 'Elastic Packages Repository'

* `gpg_key (String)` default: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

* `apt_uri (String, NilClass)` default: `https://artifacts.elastic.co/packages/#{major_version}.x/apt`

* `apt_components (Array)` default: %w[stable main]

* `apt_distribution (String)` default: ''

* `yum_baseurl (String, NilClass)` default: `https://artifacts.elastic.co/packages/#{major_version}.x/yum`

* `yum_gpgcheck (TrueClass, FalseClass)` default: true

* `yum_enabled (TrueClass, FalseClass)` default: true

* `yum_priority (String, NilClass)` default: %w[amazon].include?(node['platform_family']) ? '10' : nil

* `yum_metadata_expire (String)` default: '3h'


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests (`rake & rake knife`), ensuring they all pass
6. Write new resource/attribute description to `README.md`
7. Write description about changes to PR
8. Submit a Pull Request using Github


## Copyright & License

Authors:: Virender Khatri and [Contributors]

<pre>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>


[Chef]: https://www.chef.io/
[Contributors]: https://github.com/vkhatri/chef-elastic-repo/graphs/contributors
[Elastic]: https://www.elastic.co/
