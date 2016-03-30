require 'smart_proxy_dns_plugin_template/dns_plugin_template_version'

module Proxy::Dns::Infoblox
  class Plugin < ::Proxy::Provider
    plugin :dns_plugin_template, ::Proxy::Dns::Infoblox::VERSION

    # Settings listed under default_settings are required.
    # An exception will be raised if they are initialized with nil values.
    # Settings not listed under default_settings are considered optional and by default have nil value.
    default_settings :infoblox_user => 'infoblox', :infoblox_pw => 'infoblox', :infoblox_host => 'infoblox.my.domain'

    requires :dns, '>= 1.11'

    validate_presence :infoblox_user, :infoblox_pw, :infoblox_host

    after_activation do
      require 'smart_proxy_dns_plugin_template/dns_plugin_template_main'
      require 'smart_proxy_dns_plugin_template/dns_plugin_template_dependencies'
    end
  end
end
