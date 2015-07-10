require 'test_helper'

require 'smart_proxy_dns_plugin_template/dns_plugin_template_main'

class DnsPluginTemplateRecordTest < Test::Unit::TestCase
  # Test that a missing :example_setting throws an error
  def test_initialize_without_settings
    assert_raise(RuntimeError) do
      klass.new(settings.delete_if { |k,v| k == :example_setting })
    end
  end

  # Test that correct initialization works
  def test_initialize_with_settings
    assert_nothing_raised do
      klass.new(settings)
    end
  end

  # Test A record creation
  def test_create_a
    # Use mocha to expect any calls to backend services to prevent creating real records
    #   MyService.expects(:create).with(:ip => '10.1.1.1', :name => 'test.example.com').returns(true)

    assert klass.new(settings).create
  end

  # Test A record creation fails if the record exists
  def test_create_a_conflict
    # Use mocha to expect any calls to backend services to prevent creating real records
    #   MyService.expects(:create).with(:ip => '10.1.1.1', :name => 'test.example.com').returns(false)

    assert_raise(Proxy::Dns::Collision) { klass.new(settings).create }
  end

  # Test PTR record creation
  def test_create_ptr
    # Use mocha to expect any calls to backend services to prevent creating real records
    #   MyService.expects(:create_reverse).with(:ip => '10.1.1.1', :name => 'test.example.com').returns(true)

    assert klass.new(settings.merge(:type => 'PTR')).create
  end

  # Test PTR record creation fails if the record exists
  def test_create_ptr_conflict
    # Use mocha to expect any calls to backend services to prevent creating real records
    #   MyService.expects(:create_reverse).with(:ip => '10.1.1.1', :name => 'test.example.com').returns(false)

    assert_raise(Proxy::Dns::Collision) { klass.new(settings.merge(:type => 'PTR')).create }
  end

  # Test A record removal
  def test_remove_a
    # Use mocha to expect any calls to backend services to prevent deleting real records
    #   MyService.expects(:delete).with(:name => 'test.example.com').returns(true)

    assert klass.new(settings).remove
  end

  # Test A record removal fails if the record doesn't exist
  def test_remove_a_not_found
    # Use mocha to expect any calls to backend services to prevent deleting real records
    #   MyService.expects(:delete).with(:name => 'test.example.com').returns(false)

    assert_raise(Proxy::Dns::NotFound) { assert klass.new(settings).remove }
  end

  # Test PTR record removal
  def test_remove_ptr
    # Use mocha to expect any calls to backend services to prevent deleting real records
    #   MyService.expects(:delete).with(:ip => '10.1.1.1').returns(true)

    assert klass.new(settings.merge(:type => 'PTR')).remove
  end

  # Test PTR record removal fails if the record doesn't exist
  def test_remove_ptr_not_found
    # Use mocha to expect any calls to backend services to prevent deleting real records
    #   MyService.expects(:delete).with(:ip => '10.1.1.1').returns(false)

    assert_raise(Proxy::Dns::NotFound) { assert klass.new(settings.merge(:type => 'PTR')).remove }
  end

  private

  def klass
    Proxy::Dns::PluginTemplate::Record
  end

  def settings
    {
      :example_setting => 'foo',
      :fqdn => 'test.example.com',
      :value => '10.1.1.1',
      :type => 'A'
    }
  end
end
