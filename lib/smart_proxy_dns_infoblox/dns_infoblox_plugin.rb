module Proxy::Dns::Infoblox
  class Plugin < ::Proxy::Provider
    plugin :dns_infoblox, ::Proxy::Dns::Infoblox::VERSION

    default_settings :username => 'infoblox', :password => 'infoblox', :dns_server => 'localhost', :dns_view => 'default', :timeout => 60

    requires :dns, '>= 1.12'

    load_classes ::Proxy::Dns::Infoblox::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::Dns::Infoblox::PluginConfiguration
  end
end
