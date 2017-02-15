require 'test_helper'
require 'dns_common/dns_common'
require 'infoblox'
require 'smart_proxy_dns_infoblox/dns_infoblox_main'


class InfobloxTest < Test::Unit::TestCase
  class DummyRecord
    attr_accessor :ipv6addr, :view
  end

  def setup
    @provider = Proxy::Dns::Infoblox::Record.new('a_host', nil, 999)
  end

  def test_create_a
    fqdn = 'test.example.com'
    ip = '10.1.1.1'

    @provider.expects(:ib_create).with(Infoblox::Arecord, :name => fqdn, :ipv4addr => ip)
    @provider.do_create(fqdn, ip, 'A')
  end

  def test_create_aaaa
    fqdn = 'test.example.com'
    ip = '2002:fc80::2'

    @provider.expects(:ib_create).with(Infoblox::AAAArecord, :name => fqdn, :ipv6addr => ip)
    @provider.do_create(fqdn, ip, 'AAAA')
  end

  def test_create_cname
    fqdn = 'test.example.com'
    target = 'test-2.example.com'

    @provider.expects(:ib_create).with(Infoblox::Cname, :name => fqdn, :canonical => target)
    @provider.do_create(fqdn, target, 'CNAME')
  end

  def test_create_ptr
    fqdn = 'test.example.com'
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'

    @provider.expects(:ib_create).with(Infoblox::Ptr, :ptrdname => fqdn, :ipv4addr => ip, :ipv6addr => nil)
    @provider.do_create(ptr, fqdn, 'PTR')
  end

  def test_create_ptr_v6
    fqdn = 'test.example.com'
    ptr = '8.0.0.0.7.0.0.0.6.0.0.0.5.0.0.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.ip6.arpa'
    ip = '1:2:3:4:5:6:7:8'

    @provider.expects(:ib_create).with(Infoblox::Ptr, :ptrdname => fqdn, :ipv4addr => nil, :ipv6addr => ip)
    @provider.do_create(ptr, fqdn, 'PTR')
  end

  def test_remove_a
    fqdn = 'test.example.com'

    @provider.expects(:ib_delete).with(Infoblox::Arecord, :name => fqdn)
    @provider.do_remove(fqdn, 'A')
  end

  def test_remove_aaaa
    fqdn = 'test.example.com'

    @provider.expects(:ib_delete).with(Infoblox::AAAArecord, :name => fqdn)
    @provider.do_remove(fqdn, 'AAAA')
  end

  def test_remove_cname
    fqdn = 'test.example.com'

    @provider.expects(:ib_delete).with(Infoblox::Cname, :name => fqdn)
    @provider.do_remove(fqdn, 'CNAME')
  end

  def test_remove_ptr
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'

    @provider.expects(:ib_delete).with(Infoblox::Ptr, :ipv4addr => ip, :ipv6addr => nil)
    @provider.do_remove(ptr, 'PTR')
  end

  def test_remove_ptr_v6
    ptr = '8.0.0.0.7.0.0.0.6.0.0.0.5.0.0.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.ip6.arpa'
    ip = '1:2:3:4:5:6:7:8'

    @provider.expects(:ib_delete).with(Infoblox::Ptr, :ipv4addr => nil, :ipv6addr => ip)
    @provider.do_remove(ptr, 'PTR')
  end
end
