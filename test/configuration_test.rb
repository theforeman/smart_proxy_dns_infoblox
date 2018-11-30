require 'test_helper'
require 'infoblox'
require 'smart_proxy_dns_infoblox/plugin_configuration'

class InfobloxProviderWiringTest < Test::Unit::TestCase
  def setup
    @container = ::Proxy::DependencyInjection::Container.new
    @config = ::Proxy::Dns::Infoblox::PluginConfiguration.new
  end

  def test_connection_wiring
    @config.load_dependency_injection_wirings(@container, :username => 'user', :password => 'password', :dns_server => 'a_host')
    connection = @container.get_dependency(:connection)

    assert_equal 'user', connection.username
    assert_equal 'password', connection.password
    assert_equal 'https://a_host', connection.host
    assert_equal({:verify => true}, connection.ssl_opts)
  end

  def test_dns_provider_wiring
    @config.load_dependency_injection_wirings(@container, :username => 'user', :password => 'password', :dns_server => 'a_host')
    provider = @container.get_dependency(:dns_provider)

    assert !provider.connection.nil?
    assert_equal 'a_host', provider.server
  end
end
