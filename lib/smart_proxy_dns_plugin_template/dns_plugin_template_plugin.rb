require 'smart_proxy_dns_plugin_template/dns_plugin_template_version'

module Proxy::Dns::PluginTemplate
  class Plugin < ::Proxy::Provider
    plugin :dns_plugin_template, ::Proxy::Dns::PluginTemplate::VERSION,
           :factory => proc { |attrs| ::Proxy::Dns::PluginTemplate::Record.record(attrs) }

    requires :dns, '>= 1.10'

    after_activation do
      require 'smart_proxy_dns_plugin_template/dns_plugin_template_main'
    end
  end
end
