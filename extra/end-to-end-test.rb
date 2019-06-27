require 'rest-client'
require 'json'
require 'pp'

# subnets and domains must exist on Infoblox
URL = ENV['FOREMAN_PROXY_URL'] || "http://localhost:8000"
DNS_DOMAIN = ENV['IBX_DNS_DOMAIN'] || "example.com"
DNS_IPV4 = ENV['IBX_DNS_IPV4'] || "192.0.2.1"
DNS_IPV6 = ENV['IBX_DNS_IPV6'] || "2001:db8::1"
DNS_PTR4 = ENV['IBX_DNS_PTR4'] || "1.2.0.192.in-addr.arpa"
DNS_PTR6 = ENV['IBX_DNS_PTR6'] || "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa"

def do_get(path)
  RestClient.get("#{URL}#{path}")
end

def do_post(path, body = nil, params = {})
  RestClient.post("#{URL}#{path}", body, params.merge({content_type: :json}))
end

def do_delete(path, params = {})
  RestClient.delete("#{URL}#{path}", params.merge({content_type: :json}))
end

features = JSON.parse(do_get("/v2/features"))

if features["dns"]["state"] == "running"
  fqdn = "end2end.#{DNS_DOMAIN}"
  cname = "alias-end2end.#{DNS_DOMAIN}"
  puts "Performing DNS tests with #{fqdn}"
  begin
    do_post("/dns?type=a&fqdn=#{fqdn}&value=#{DNS_IPV4}")
    do_post("/dns?type=a&fqdn=#{fqdn}&value=#{DNS_IPV4}") # skip (already exists)
    begin
      do_post("/dns?type=a&fqdn=#{fqdn}&value=192.0.2.1")
      raise "Expected conflict not returned"
    rescue RestClient::Conflict
      # expected
    end
  ensure
    do_delete("/dns/#{fqdn}/A")
  end
  begin
    do_post("/dns?type=aaaa&fqdn=#{fqdn}&value=#{DNS_IPV6}")
    do_post("/dns?type=aaaa&fqdn=#{fqdn}&value=#{DNS_IPV6}") # skip (already exists)
    begin
      do_post("/dns?type=aaaa&fqdn=#{fqdn}&value=2001:db8::2")
      raise "Expected conflict not returned"
    rescue RestClient::Conflict
      # expected
    end
  ensure
    do_delete("/dns/#{fqdn}/AAAA")
  end
  begin
    do_post("/dns?type=cname&fqdn=#{fqdn}&value=#{cname}")
    do_post("/dns?type=cname&fqdn=#{fqdn}&value=#{cname}") # skip (already exists)
    begin
      do_post("/dns?type=cname&fqdn=#{fqdn}&value=a2-#{cname}")
      raise "Expected conflict not returned"
    rescue RestClient::Conflict
      # expected
    end
  ensure
    do_delete("/dns/#{fqdn}/CNAME")
  end
  begin
    do_post("/dns?type=ptr&fqdn=#{fqdn}&value=#{DNS_PTR4}")
    do_post("/dns?type=ptr&fqdn=#{fqdn}&value=#{DNS_PTR4}") # skip (already exists)
    begin
      do_post("/dns?type=ptr&fqdn=#{fqdn}&value=14.202.168.192.in-addr.arpa")
      raise "Expected conflict not returned"
    rescue RestClient::Conflict
      # expected
    end
  ensure
    do_delete("/dns/#{DNS_PTR4}/PTR")
  end
  begin
    do_post("/dns?type=ptr&fqdn=#{fqdn}&value=#{DNS_PTR6}")
    do_post("/dns?type=ptr&fqdn=#{fqdn}&value=#{DNS_PTR6}") # skip (already exists)
    begin
      do_post("/dns?type=ptr&fqdn=#{fqdn}&value=1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.9.b.d.0.1.0.0.2.ip6.arpa")
      raise "Expected conflict not returned"
    rescue RestClient::Conflict
      # expected
    end
  ensure
    do_delete("/dns/#{DNS_PTR6}/PTR")
  end
end
