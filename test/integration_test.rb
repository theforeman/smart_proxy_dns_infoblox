require 'test_helper'
require 'dns_common/dns_common'
require 'smart_proxy_dns_infoblox'
require 'smart_proxy_dns_infoblox/dns_infoblox_main'
require "rack/test"
require 'json'

module Proxy::Dns
  module DependencyInjection
    include Proxy::DependencyInjection::Accessors
    def container_instance; end
  end
end

require 'dns/dns_api'

ENV['RACK_ENV'] = 'test'

class IntegrationTest < ::Test::Unit::TestCase
  include Rack::Test::Methods

  class DnsProviderForTesting < Proxy::Dns::Infoblox::Record
    def initialize; end
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

  def test_create_ptr_record
    @server.expects(:create_ptr_record).with("test.com", "33.33.168.192.in-addr.arpa")
    post '/', :fqdn => 'test.com', :value => '33.33.168.192.in-addr.arpa', :type => 'PTR'
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
