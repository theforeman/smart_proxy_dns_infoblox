require 'dns/dns'

module Proxy::Dns::PluginTemplate
  class Record < ::Proxy::Dns::Record
    include Proxy::Log
    include Proxy::Util

    attr_reader :example_setting

    def self.record(attrs = {})
      new(attrs.merge(:example_setting => ::Proxy::Dns::PluginTemplate::Plugin.settings.example_setting))
    end

    def initialize options = {}
      @example_setting = options[:example_setting]
      raise "dns_plugin_template provider needs 'example_setting' option" unless example_setting
      super(options)
    end

    def create
      case @type
        when "A"
          # FIXME: add a forward 'A' record with @fqdn, @ttl, @type, @value (IP)
          #
          # Raise an error if the FQDN is already in DNS but with a different IP:
          #   raise(Proxy::Dns::Collision, "#{@fqdn} is already used by #{ip}")

          true
        when "PTR"
          # FIXME: add a reverse 'PTR' record with @value (IP), @fqdn, @ttl, @type
          #
          # Raise an error if the IP is already in DNS but with a different FQDN:
          #   raise(Proxy::Dns::Collision, "#{@value} is already used by #{name}")

          true
      end
    end

    def remove
      case @type
        when "A"
          # FIXME: remove the forward 'A' record with @fqdn, @ttl, @type, @value (IP)
          #
          # Raise an error if the FQDN is not in DNS:
          #   raise Proxy::Dns::NotFound.new("Cannot find DNS entry for #{@fqdn}")

          true
        when "PTR"
          # FIXME: remove the reverse 'PTR' record with @value (IP), @fqdn, @ttl, @type
          #
          # Raise an error if the IP is not in DNS:
          #   raise Proxy::Dns::NotFound.new("Cannot find DNS entry for #{@value}")

          true
      end
    end
  end
end
