require 'dns/dns'
require 'dns_common/dns_common'
require 'infoblox'
module Proxy::Dns::Infoblox
  class Record < ::Proxy::Dns::Record
    include Proxy::Log
    include Proxy::Util

    attr_reader :example_setting, :optional_path, :required_setting, :required_path

    def initialize
      @infoblox_user = ::Proxy::Dns::Infoblox::Plugin.settings.infoblox_user
      @infoblox_pw   = ::Proxy::Dns::Infoblox::Plugin.settings.infoblox_pw
      @infoblox_host = ::Proxy::Dns::Infoblox::Plugin.settings.infoblox_host
      @conn          = ::Infoblox::Connection.new(username: @infoblox_user ,password: @infoblox_pw, host: @infoblox_host)
      super('localhost', ::Proxy::Dns::Plugin.settings.dns_ttl)
    end

    # Calls to these methods are guaranteed to have non-nil parameters
    def create_a_record(fqdn, ip)
      raise(Proxy::Dns::Collision, "#{fqdn} is already used by #{ip_in_use}") if dns_find(fqdn)

      a_record = Infoblox::Arecord.new(connection: @conn, name: fqdn, ipv4addr: ip)
      a_record.post
    end

    def create_ptr_record(fqdn, ip)
      raise(Proxy::Dns::Collision, "#{ip} is already used by #{fqdn_in_use}") if dns_find(ip)

      ptr_record = Infoblox::Ptr.new(connection: @conn, ptrdname: fqdn, ip4vaddr: ip)
      ptr_record.post
      # FIXME: add a reverse 'PTR' record with ip, fqdn
      # Raise an error if the IP is already in DNS but with a different FQDN:
      #   raise(Proxy::Dns::Collision, "#{ip} is already used by #{fqdn_in_use}")
    end

    def remove_a_record(fqdn)
      a_record = Infoblox::Arecord.find( @conn, {name: fqdn}).first
      a_record.delete || raise(Proxy::Dns::NotFound.new("Cannot find DNS entry for #{fqdn}"))
    end

    def remove_ptr_record(ip)
      ptr_record = Infoblox::Ptr.find(@conn, { ipv4addr: ip }).first
      ptr_record.delete || raise(Proxy::Dns::NotFound.new("Cannot find DNS entry for #{ip}"))
      # FIXME: remove the reverse 'PTR' record with ip
      # Raise an error if the IP is not in DNS:
      #   raise Proxy::Dns::NotFound.new("Cannot find DNS entry for #{ip}")
    end
  end
end
