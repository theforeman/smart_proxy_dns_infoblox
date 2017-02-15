module Proxy::Dns::Infoblox
  class Record < ::Proxy::Dns::Record
    attr_reader :connection

    def initialize(host, connection, ttl)
      ENV['WAPI_VERSION']='2.0'
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
      ib_create(Infoblox::Ptr, :ptrdname => fqdn,
                               :ipv4addr => (ip.ipv4? && ip.to_s || nil),
                               :ipv6addr => (ip.ipv6? && ip.to_s || nil))
    end

    def ib_remove_ptr_record(ptr)
      ip = IPAddr.new(ptr_to_ip(ptr))
      ib_delete(Infoblox::Ptr, :ipv4addr => (ip.ipv4? && ip.to_s || nil), :ipv6addr => (ip.ipv6? && ip.to_s || nil))
    end

    def ib_create(clazz, params)
      clazz.new({ :connection => connection }.merge(params)).post
    end

    def ib_delete(clazz, params)
      record = clazz.find(connection, params.merge(:_max_results => 1)).first

      raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}" if record.nil?
      record.delete || (raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}")
    end
  end
end
