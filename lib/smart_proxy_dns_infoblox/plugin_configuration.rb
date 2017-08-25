module Proxy::Dns::Infoblox
  class PluginConfiguration
    def load_classes
      require 'infoblox'
      require 'dns_common/dns_common'
      require 'smart_proxy_dns_infoblox/dns_infoblox_main'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.dependency :connection,
                                    (lambda do
                                      ::Infoblox.wapi_version = '1.4.2'
                                      ::Infoblox::Connection.new(:username => settings[:username],
                                                                 :password => settings[:password],
                                                                 :host => settings[:dns_server],
                                                                 :ssl_opts => {:verify => false})
                                    end)
      container_instance.dependency :dns_provider,
                                    lambda {::Proxy::Dns::Infoblox::Record.new(
                                        settings[:dns_server],
                                        container_instance.get_dependency(:connection),
                                        settings[:dns_ttl],
					settings[:dns_view]) }
    end
  end
end
