module Proxy::Dns::Infoblox
  class Record < ::Proxy::Dns::Record
    attr_reader :connection

    def initialize(host, connection, ttl)
      ENV['WAPI_VERSION']='2.0'
      @connection = connection
      super(host, ttl)
    end

    def create_a_record(fqdn, ip)
      case a_record_conflicts(fqdn.to_s, ip.to_s) #returns -1, 0, 1
      when 1
        raise(Proxy::Dns::Collision, "'#{fqdn} 'is already in use")
      when 0 then
        return nil
      else
        do_create(Infoblox::Arecord, :connection => connection, :name => fqdn, :ipv4addr => ip)
      end
    end

    def create_ptr_record(fqdn, ptr)
      case ptr_record_conflicts(fqdn.to_s, ptr_to_ip(ptr).to_s) #returns -1, 0, 1
      when 1
        raise(Proxy::Dns::Collision, "'#{fqdn} 'is already in use")
      when 0 then
        return nil
      else
        do_create(Infoblox::Ptr, :connection => connection, :ptrdname => fqdn, :ipv4addr => ptr_to_ip(ptr))
      end
      # FIXME: add a reverse 'PTR' record with ip, fqdn
    end

    def remove_a_record(fqdn)
      do_delete(Infoblox::Arecord.find(connection, :name => fqdn, :_max_results => 1).first, fqdn)
    end

    def remove_ptr_record(ptr)
      ptr_record = Infoblox::Ptr.find(connection, :ipv4addr => ptr_to_ip(ptr), :_max_results => 1).first
      unless ptr_record.nil?
        ptr_record.ipv6addr = nil
        ptr_record.view = nil
      end

      do_delete(ptr_record, ptr)
      # FIXME: remove the reverse 'PTR' record with ip
    end

    def do_create(clazz, params)
      clazz.new(params).post
    end

    def do_delete(record, id)
      raise Proxy::Dns::NotFound, "Cannot find DNS entry for #{id}" if record.nil?
      record.delete || (raise Proxy::Dns::NotFound, "Cannot find DNS entry for #{id}")
    end
  end
end
