module Proxy::Dns::Infoblox
  class Record < ::Proxy::Dns::Record
    attr_reader :connection, :dns_view

    def initialize(host, connection, ttl, dns_view)
      @connection = connection
      @dns_view = dns_view
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

    # -1 = no conflict and create the record
    #  0 = already exists and do nothing
    #  1 = conflict and error out
    def record_conflicts_ip(fqdn, type, address)
      if type == Resolv::DNS::Resource::IN::PTR
        ip = IPAddr.new(ptr_to_ip(address))
        method = "ib_find_#{type.name.split('::').last.downcase}#{ip.ipv4? ? 4 : 6}_record".to_sym
      else
        method = "ib_find_#{type.name.split('::').last.downcase}_record".to_sym
      end
      raise(Proxy::Dns::Error, "Finding of #{type} records not implemented") unless respond_to?(method, true)

      return -1 if send(method, fqdn).empty?
      return 0 if send(method, fqdn, address).any?

      1
    end

    def record_conflicts_name(fqdn, type, content)
      if type == Resolv::DNS::Resource::IN::PTR
        record_conflicts_ip(content, type, fqdn)
      else
        record_conflicts_ip(fqdn, type, content)
      end
    end

    private

    def ib_find_a_record(fqdn, address = nil)
      params = {
        :_max_results => 1,
        :view => dns_view,
        :name => fqdn
      }
      params[:ipv4addr] = address if address
      Infoblox::Arecord.find(connection, params)
    end

    def ib_find_aaaa_record(fqdn, address = nil)
      params = {
        :_max_results => 1,
        :view => dns_view,
        :name => fqdn
      }
      params[:ipv6addr] = address if address
      Infoblox::AAAArecord.find(connection, params)
    end

    def ib_find_ptr4_record(fqdn, ptr = nil)
      params = {
        :_max_results => 1,
        :view => dns_view,
        :ptrdname => fqdn,
        :'name~' => 'in-addr\.arpa$'
      }
      if ptr
        ip = IPAddr.new(ptr_to_ip(ptr))
        params[:ipv4addr] = ip.to_s
        params[:name] = ptr
      end
      Infoblox::Ptr.find(connection, params)
    end

    def ib_find_ptr6_record(fqdn, ptr = nil)
      params = {
        :_max_results => 1,
        :view => dns_view,
        :ptrdname => fqdn,
        :'name~' => 'ip6\.arpa$'
      }
      if ptr
        ip = IPAddr.new(ptr_to_ip(ptr))
        params[:ipv6addr] = ip.to_s
        params[:name] = ptr
      end
      Infoblox::Ptr.find(connection, params)
    end

    def ib_find_cname_record(fqdn, address = nil)
      params = {
        :_max_results => 1,
        :view => dns_view,
        :name => fqdn
      }
      params[:canonical] = address if address
      Infoblox::Cname.find(connection, params)
    end

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
      clazz.new({ connection: connection, view: dns_view }.merge(params)).post
    end

    def ib_delete(clazz, params)
      record = clazz.find(connection, params.merge(_max_results: 1, view: dns_view)).first

      raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}" if record.nil?

      ret_value = record.delete || (raise Proxy::Dns::NotFound, "Cannot find #{clazz.class.name} entry for #{params}")

      ib_clear_dns_cache(record)

      ret_value
    end

    def ib_clear_dns_cache(record)
      # Created in WAPI version 2.6
      return if Gem::Version.new(Infoblox.wapi_version) < Gem::Version.new('2.6')

      MemberDns.all(connection).each do |member|
        member.clear_dns_cache(view: record.view, domain: record.name)
      end
    rescue StandardError => e
      # Failing to clear the DNS cache should never be an error
      logger.warn("Exception #{e} was raised when clearing DNS cache")
    end
  end
end
