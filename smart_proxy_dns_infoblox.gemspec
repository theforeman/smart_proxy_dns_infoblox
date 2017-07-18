require File.expand_path('../lib/smart_proxy_dns_infoblox/dns_infoblox_version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_infoblox'
  s.version     = Proxy::Dns::Infoblox::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['Matthew Nicholson']
  s.email       = ['matthew.a.nicholson@gmail.com']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_dns_infoblox'

  s.summary     = "Infoblox DNS provider plugin for Foreman's smart proxy"
  s.description = "Infoblox DNS provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']
end
