require 'test_helper'
require 'dns_common/dns_common'
require 'infoblox'
require 'smart_proxy_dns_infoblox/dns_infoblox_main'
require 'smart_proxy_dns_infoblox/infoblox_member_dns'

class InfobloxTest < Test::Unit::TestCase
  class DummyRecord
    attr_accessor :ipv6addr, :view
  end

  def setup
    @provider = Proxy::Dns::Infoblox::Record.new('a_host', nil, 999, 'default.test')
  end

  def test_conflict_a_ok
    @provider.expects(:ib_find_a_record).with("test.example.com").returns([])
    assert_equal(-1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::A, "1.2.3.4"))
  end

  def test_conflict_a_already_exists
    @provider.expects(:ib_find_a_record).with("test.example.com").returns([true])
    @provider.expects(:ib_find_a_record).with("test.example.com", "1.2.3.4").returns([true])
    assert_equal(0, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::A, "1.2.3.4"))
  end

  def test_conflict_a_conflict
    @provider.expects(:ib_find_a_record).with("test.example.com").returns([false])
    @provider.expects(:ib_find_a_record).with("test.example.com", "1.2.3.4").returns([false])
    assert_equal(1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::A, "1.2.3.4"))
  end

  def test_conflict_aaaa_ok
    @provider.expects(:ib_find_aaaa_record).with("test.example.com").returns([])
    assert_equal(-1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::AAAA, "1.2.3.4"))
  end

  def test_conflict_aaaa_already_exists
    @provider.expects(:ib_find_aaaa_record).with("test.example.com").returns([true])
    @provider.expects(:ib_find_aaaa_record).with("test.example.com", "1.2.3.4").returns([true])
    assert_equal(0, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::AAAA, "1.2.3.4"))
  end

  def test_conflict_aaaa_conflict
    @provider.expects(:ib_find_aaaa_record).with("test.example.com").returns([false])
    @provider.expects(:ib_find_aaaa_record).with("test.example.com", "1.2.3.4").returns([false])
    assert_equal(1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::AAAA, "1.2.3.4"))
  end

  def test_conflict_ptr_ok
    @provider.expects(:ib_find_ptr_record).with("13.202.168.192.in-addr.arpa").returns([])
    assert_equal(-1, @provider.record_conflicts_ip("13.202.168.192.in-addr.arpa", Resolv::DNS::Resource::IN::PTR, "test.example.com"))
  end

  def test_conflict_ptr_already_exists
    @provider.expects(:ib_find_ptr_record).with("13.202.168.192.in-addr.arpa").returns([true])
    @provider.expects(:ib_find_ptr_record).with("13.202.168.192.in-addr.arpa", "test.example.com").returns([true])
    assert_equal(0, @provider.record_conflicts_ip("13.202.168.192.in-addr.arpa", Resolv::DNS::Resource::IN::PTR, "test.example.com"))
  end

  def test_conflict_ptr_conflict
    @provider.expects(:ib_find_ptr_record).with("13.202.168.192.in-addr.arpa").returns([false])
    @provider.expects(:ib_find_ptr_record).with("13.202.168.192.in-addr.arpa", "test.example.com").returns([false])
    assert_equal(1, @provider.record_conflicts_ip("13.202.168.192.in-addr.arpa", Resolv::DNS::Resource::IN::PTR, "test.example.com"))
  end

  def test_conflict_cname_ok
    @provider.expects(:ib_find_cname_record).with("test.example.com").returns([])
    assert_equal(-1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::CNAME, "alias.example.com"))
  end

  def test_conflict_cname_already_exists
    @provider.expects(:ib_find_cname_record).with("test.example.com").returns([true])
    @provider.expects(:ib_find_cname_record).with("test.example.com", "alias.example.com").returns([true])
    assert_equal(0, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::CNAME, "alias.example.com"))
  end

  def test_conflict_cname_conflict
    @provider.expects(:ib_find_cname_record).with("test.example.com").returns([false])
    @provider.expects(:ib_find_cname_record).with("test.example.com", "alias.example.com").returns([false])
    assert_equal(1, @provider.record_conflicts_ip("test.example.com", Resolv::DNS::Resource::IN::CNAME, "alias.example.com"))
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

    @provider.expects(:ib_create).with(Infoblox::Ptr, :name => ptr, :ptrdname => fqdn, :ipv4addr => ip)
    @provider.do_create(ptr, fqdn, 'PTR')
  end

  def test_create_ptr_v6
    fqdn = 'test.example.com'
    ptr = '8.0.0.0.7.0.0.0.6.0.0.0.5.0.0.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.ip6.arpa'
    ip = '1:2:3:4:5:6:7:8'

    @provider.expects(:ib_create).with(Infoblox::Ptr, :name => ptr, :ptrdname => fqdn, :ipv6addr => ip)
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

    @provider.expects(:ib_delete).with(Infoblox::Ptr, :ipv4addr => ip)
    @provider.do_remove(ptr, 'PTR')
  end

  def test_remove_ptr_v6
    ptr = '8.0.0.0.7.0.0.0.6.0.0.0.5.0.0.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.ip6.arpa'
    ip = '1:2:3:4:5:6:7:8'

    @provider.expects(:ib_delete).with(Infoblox::Ptr, :ipv6addr => ip)
    @provider.do_remove(ptr, 'PTR')
  end

  def test_wapi_old
    fqdn = 'test.example.com'
    record = Infoblox::Arecord.new name: fqdn
    record.stubs(:delete).returns(record)

    old_version = Infoblox.wapi_version
    Infoblox.wapi_version = '2.0'

    Infoblox::Arecord.expects(:find).returns([record])
    Proxy::Dns::Infoblox::MemberDns.expects(:all).never
    @provider.do_remove(fqdn, 'A')
  ensure
    Infoblox.wapi_version = old_version
  end

  def test_wapi_new
    fqdn = 'test.example.com'
    record = Infoblox::Arecord.new name: fqdn, view: 'test'
    record.stubs(:delete).returns(record)
    member = Proxy::Dns::Infoblox::MemberDns.new name: 'ns1.example.com'

    old_version = Infoblox.wapi_version
    Infoblox.wapi_version = '2.7'

    Infoblox::Arecord.expects(:find).returns([record])
    Proxy::Dns::Infoblox::MemberDns.expects(:all).returns([member])
    member.expects(:clear_dns_cache).with(view: 'test', domain: fqdn)
    @provider.do_remove(fqdn, 'A')
  ensure
    Infoblox.wapi_version = old_version
  end
end
