require File.expand_path('lib/smart_proxy_dns_infoblox/dns_infoblox_version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_infoblox'
  s.version     = Proxy::Dns::Infoblox::VERSION
  s.license     = 'GPL-3.0-only'
  s.authors     = ['Matthew Nicholson']
  s.email       = ['matthew.a.nicholson@gmail.com']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_dns_infoblox'

  s.summary     = "Infoblox DNS provider plugin for Foreman's smart proxy"
  s.description = "Infoblox DNS provider plugin for Foreman's smart proxy."

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency('infoblox', '~> 3.0')
end
