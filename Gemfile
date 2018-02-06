source 'https://rubygems.org'
gemspec

gem 'infoblox', '>= 0.4.1'
if RUBY_VERSION < '2.0.0'
  gem 'json', '< 2.0.0', :require => false
end

group :development do
  gem 'rake'
  gem 'test-unit'

  if RUBY_VERSION < '2.2.2'
    gem 'rack-test', '~> 0.7.0'
  else
    gem 'rack-test'
  end

  gem 'mocha'
  gem 'smart_proxy', :github => 'theforeman/smart-proxy', :branch => 'develop'
end
