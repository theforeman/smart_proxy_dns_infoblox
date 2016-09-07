require 'test_helper'
require 'dns_common/dns_common'
require 'infoblox'
require 'smart_proxy_dns_infoblox/dns_infoblox_main'


class InfobloxTest < Test::Unit::TestCase
  class DummyRecord
    attr_accessor :ipv6addr, :view
  end

  def setup
    @connection = Object.new
    @record = DummyRecord.new
    @provider = Proxy::Dns::Infoblox::Record.new('a_host', @connection, 999)
  end

  def test_create_a
    fqdn = 'test.example.com'
    ip = '10.1.1.1'

    @provider.expects(:a_record_conflicts).with(fqdn, ip).returns(-1)
    @provider.expects(:do_create).with(Infoblox::Arecord, :connection => @connection, :name => fqdn, :ipv4addr => ip)

    @provider.create_a_record(fqdn, ip)
  end

  def test_create_a_conflicting_record
    fqdn = 'test.example.com'
    ip = '10.1.1.1'

    @provider.expects(:a_record_conflicts).with(fqdn, ip).returns(1)
    assert_raises(Proxy::Dns::Collision) { @provider.create_a_record(fqdn, ip) }
  end

  def test_create_a_already_exists
    fqdn = 'test.example.com'
    ip = '10.1.1.1'

    @provider.expects(:a_record_conflicts).with(fqdn, ip).returns(0)
    assert_nil @provider.create_a_record(fqdn, ip)
  end

  def test_create_ptr
    fqdn = 'test.example.com'
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'

    @provider.expects(:ptr_record_conflicts).with(fqdn, ip).returns(-1)
    @provider.expects(:do_create).with(Infoblox::Ptr, :connection => @connection, :ptrdname => fqdn, :ipv4addr => ip)

    @provider.create_ptr_record(fqdn, ptr)
  end

  def test_create_ptr_conflicting_record
    fqdn = 'test.example.com'
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'

    @provider.expects(:ptr_record_conflicts).with(fqdn, ip).returns(1)
    assert_raises(Proxy::Dns::Collision) { @provider.create_ptr_record(fqdn, ptr) }
  end

  def test_create_ptr_already_exists
    fqdn = 'test.example.com'
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'

    @provider.expects(:ptr_record_conflicts).with(fqdn, ip).returns(0)
    assert_nil @provider.create_ptr_record(fqdn, ptr)
  end

  def test_remove_a
    fqdn = 'test.example.com'
    Infoblox::Arecord.expects(:find).with(@connection, :name => fqdn, :_max_results => 1).returns([@record])
    @record.expects(:delete).returns(true)
    @provider.remove_a_record(fqdn)
  end

  def test_remove_a_not_found
    fqdn = 'test.example.com'
    Infoblox::Arecord.expects(:find).with(@connection, :name => fqdn, :_max_results => 1).returns([])
    assert_raises(Proxy::Dns::NotFound) { @provider.remove_a_record(fqdn) }
  end

  def test_remove_a_returns_with_a_non_200_status
    fqdn = 'test.example.com'
    Infoblox::Arecord.expects(:find).with(@connection, :name => fqdn, :_max_results => 1).returns([@record])
    @record.expects(:delete).returns(false)
    assert_raises(Proxy::Dns::NotFound) { @provider.remove_a_record(fqdn) }
  end

  def test_remove_ptr
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'
    Infoblox::Ptr.expects(:find).with(@connection, :ipv4addr => ip, :_max_results => 1).returns([@record])
    @record.expects(:delete).returns(true)
    @provider.remove_ptr_record(ptr)
  end

  def test_remove_ptr_not_found
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'
    Infoblox::Ptr.expects(:find).with(@connection, :ipv4addr => ip, :_max_results => 1).returns([])
    assert_raises(Proxy::Dns::NotFound) { @provider.remove_ptr_record(ptr) }
  end

  def test_remove_ptr_returns_with_a_non_200_status
    ptr = '1.1.1.10.in-addr.arpa'
    ip = '10.1.1.1'
    Infoblox::Ptr.expects(:find).with(@connection, :ipv4addr => ip, :_max_results => 1).returns([@record])
    @record.expects(:delete).returns(false)
    assert_raises(Proxy::Dns::NotFound) { @provider.remove_ptr_record(ptr) }
  end
end
