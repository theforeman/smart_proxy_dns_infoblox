require 'dns_common/dns_common'

module Proxy::Dns::PluginTemplate
  class Record < ::Proxy::Dns::Record
    include Proxy::Log
    include Proxy::Util

    attr_reader :example_setting, :optional_path, :required_setting, :required_path

    def initialize
      @required_setting = ::Proxy::Dns::PluginTemplate::Plugin.settings.required_setting # never nil
      @example_setting = ::Proxy::Dns::PluginTemplate::Plugin.settings.example_setting # can be nil
      @required_path = ::Proxy::Dns::PluginTemplate::Plugin.settings.required_path # file exists and is readable
      @optional_path = ::Proxy::Dns::PluginTemplate::Plugin.settings.optional_path # nil, or file exists and is readable

      # Common settings can be defined by the main plugin, it's ok to use them locally.
      # Please note that providers must not rely on settings defined by other providers or plugins they are not related to.
      super('localhost', ::Proxy::Dns::Plugin.settings.dns_ttl)
    end

    # Calls to these methods are guaranteed to have non-nil parameters
    def create_a_record(fqdn, ip)
      # FIXME: add a forward 'A' record with fqdn, ip
      # Raise an error if the FQDN is already in DNS but with a different IP:
      #   raise(Proxy::Dns::Collision, "#{fqdn} is already used by #{ip_in_use}")
    end

    def create_ptr_record(fqdn, ip)
      # FIXME: add a reverse 'PTR' record with ip, fqdn
      # Raise an error if the IP is already in DNS but with a different FQDN:
      #   raise(Proxy::Dns::Collision, "#{ip} is already used by #{fqdn_in_use}")
    end

    def remove_a_record(fqdn)
      # FIXME: remove the forward 'A' record with fqdn
      # Raise an error if the FQDN is not in DNS:
      #   raise Proxy::Dns::NotFound.new("Cannot find DNS entry for #{fqdn}")
    end

    def remove_ptr_record(ip)
      # FIXME: remove the reverse 'PTR' record with ip
      # Raise an error if the IP is not in DNS:
      #   raise Proxy::Dns::NotFound.new("Cannot find DNS entry for #{ip}")
    end
  end
end
