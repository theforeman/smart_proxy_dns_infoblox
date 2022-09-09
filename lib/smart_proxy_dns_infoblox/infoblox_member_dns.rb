module Proxy::Dns::Infoblox
  class MemberDns < Infoblox::Resource
    remote_attr_reader :host_name

    wapi_object 'member:dns'

    def clear_dns_cache(clear_full_tree: false,
                       domain: nil,
                       view: nil)
      post_body = {
        clear_full_tree: clear_full_tree
      }
      post_body[:domain] = domain unless domain.nil?
      post_body[:view] = view unless view.nil?

      JSON.parse(connection.post("#{resource_uri}?_function=clear_dns_cache", post_body).body)
    end
  end
end
