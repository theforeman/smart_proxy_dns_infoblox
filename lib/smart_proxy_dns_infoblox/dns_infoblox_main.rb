module Proxy::Dns::Infoblox
  class Record < ::Proxy::Dns::Record
    attr_reader :connection

    def initialize(host, connection, ttl)
      @connection = connection
      super(host, ttl)
    end

    def do_create(name, value, type)
      method = "ib_create_#{type.downcase}_record".to_sym
      raise(Proxy::Dns::Error, "Creation of #{type} records not implemented") unless respond_to?(method, true)
      send(method, name, value)
    end

    def do_remove(name, type)
      method = "ib_remove_#{type.downcase}_record".to_sym
      raise(Proxy::Dns::Error, "Deletion of #{type} records not implemented") unless respond_to?(method, true)
      send(method, name)
    end

    private

    def ib_create_a_record(fqdn, address)
      ib_create(Infoblox::Arecord, :name => fqdn, :ipv4addr => address)
    end

    def ib_remove_a_record(fqdn)
      ib_delete(Infoblox::Arecord, :name => fqdn)
    end

    def ib_create_aaaa_record(fqdn, address)
      ib_create(Infoblox::AAAArecord, :name => fqdn, :ipv6addr => address)
    end

    def ib_remove_aaaa_record(fqdn)
      ib_delete(Infoblox::AAAArecord, :name => fqdn)
    end

    def ib_create_cname_record(fqdn, target)
      ib_create(Infoblox::Cname, :name => fqdn, :canonical => target)
    end

    def ib_remove_cname_record(fqdn)
      ib_delete(Infoblox::Cname, :name => fqdn)
    end

    def ib_create_ptr_record(ptr, fqdn)
      ip = IPAddr.new(ptr_to_ip(ptr))

      params = {
        :ptrdname => fqdn,
        :name => ptr
      }
      params["ipv#{ip.ipv4? ? 4 : 6}addr".to_sym] = ip.to_s

      ib_create(Infoblox::Ptr, params)
    end

    def ib_remove_ptr_record(ptr)
      ip = IPAddr.new(ptr_to_ip(ptr))

      params = {}
      params["ipv#{ip.ipv4? ? 4 : 6}addr".to_sym] = ip.to_s

      ib_delete(Infoblox::Ptr, params)
    end

    def ib_create(clazz, params)
      clazz.new({ :connection => connection }.merge(params)).post
    end

    def ib_delete(clazz, params)
      record = clazz.find(connection, params.merge(:_max_results => 1)).first

      raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}" if record.nil?
      record.delete || (raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}")

      ib_clear_dns_cache(record)
    end

    def ib_clear_dns_cache(record)
      # Created in WAPI version 2.6
      return if Gem::Version.new(Infoblox.wapi_version) < Gem::Version.new('2.6')

      MemberDns.all(connection).each do |member|
        member.clear_dns_cache(view: record.view, domain: record.name)
      end
    rescue StandardError => ex
      # Failing to clear the DNS cache should never be an error
      logger.warn("Exception #{ex} was raised when clearing DNS cache")
    end
  end
end
