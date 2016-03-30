require File.expand_path('../lib/smart_proxy_dns_plugin_template/dns_plugin_template_version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_plugin_template'
  s.version     = Proxy::Dns::PluginTemplate::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPLv3'
  s.authors     = ['TODO: Your name']
  s.email       = ['TODO: Your email']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_dns_plugin_template'

  s.summary     = "TODO DNS provider plugin for Foreman's smart proxy"
  s.description = "TODO DNS provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
