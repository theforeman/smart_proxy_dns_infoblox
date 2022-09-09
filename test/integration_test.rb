require 'test_helper'
require 'dns_common/dns_common'
require 'smart_proxy_dns_infoblox'
require 'smart_proxy_dns_infoblox/dns_infoblox_main'
require "rack/test"
require 'json'

module Proxy::Dns
  module DependencyInjection
    include Proxy::DependencyInjection::Accessors
    def container_instance
    end
  end
end

require 'dns/dns_api'

ENV['RACK_ENV'] = 'test'

class IntegrationTest < ::Test::Unit::TestCase
  include Rack::Test::Methods

  class DnsProviderForTesting < Proxy::Dns::Infoblox::Record
    # This explicitly doesn't want to do anything
    # rubocop:disable Lint/MissingSuper Style/RedundantInitialize
    def initialize
    end
    # rubocop:enable Lint/MissingSuper Style/RedundantInitialize
  end

  def app
    app = Proxy::Dns::Api.new
    app.helpers.server = @server
    app
  end

  def setup
    @server = DnsProviderForTesting.new
  end

  def test_create_a_record
    @server.expects(:create_a_record).with("test.com", "192.168.33.33")
    post '/', :fqdn => 'test.com', :value => '192.168.33.33', :type => 'A'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_create_ptr4_record
    @server.expects(:ib_find_ptr4_record).with('test.com').returns([])
    @server.expects(:ib_create_ptr_record).with('33.33.168.192.in-addr.arpa', 'test.com')
    post '/', :fqdn => 'test.com', :value => '33.33.168.192.in-addr.arpa', :type => 'PTR'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_create_ptr6_record
    @server.expects(:ib_find_ptr6_record).with('test.com').returns([])
    @server.expects(:ib_create_ptr_record).with('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'test.com')
    post '/', :fqdn => 'test.com', :value => '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', :type => 'PTR'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_delete_a_record
    @server.expects(:remove_a_record).with("test.com")
    delete '/test.com'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_delete_ptr_record
    @server.expects(:remove_ptr_record).with("33.33.168.192.in-addr.arpa")
    delete '/33.33.168.192.in-addr.arpa'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end
end
