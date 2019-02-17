# SmartProxyDnsInfoblox

[![Build Status](https://travis-ci.org/theforeman/smart_proxy_dns_infoblox.svg?branch=master)](https://travis-ci.org/theforeman/smart_proxy_dns_infoblox)

This plugin adds a new DNS provider for managing records in MyService.

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is compatible with Smart Proxy 1.10 or higher.

Example installation command via foreman-installer:

```
# foreman-installer --enable-foreman-proxy-plugin-dns-infoblox \
--foreman-proxy-dns-provider infoblox \
--foreman-proxy-plugin-dns-infoblox-dns-server 192.168.201.2 \
--foreman-proxy-plugin-dns-infoblox-infoblox-host 192.168.201.3 \
--foreman-proxy-plugin-dns-infoblox-username admin \
--foreman-proxy-plugin-dns-infoblox-password infoblox
```

## Configuration

To enable this DNS provider, edit `/etc/foreman-proxy/settings.d/dns.yml` and set:

    :use_provider: dns_infoblox

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dns_infoblox.yml` and include:

* example_setting: change this as an example

## SSL

The plugin enforces HTTPS server certificate verification. Follow a standard CA cert installation procedure for your operating system. It's possible to either download the server certificate from Infoblox web UI or use openssl command to extract it from server response. Here are example steps for Red Hat compatible systems:

```
# update-ca-trust enable
# openssl s_client -showcerts -connect 192.168.201.2:443 </dev/null | openssl x509 -text >/etc/pki/ca-trust/source/anchors/infoblox.crt
# update-ca-trust extract
```

For Debian-compatible systems:

```
# openssl s_client -showcerts -connect 192.168.201.2:443 </dev/null | openssl x509 -text >/usr/local/share/ca-certificates/infoblox.crt
# update-ca-certificates
```

To test the CA certificate, a simple curl query can be used. This is a positive test:

```
# curl -u admin:infoblox https://192.168.201.2/wapi/v2.0/network
[
    {
        "_ref": "network/ZG5zLm5ldHdvcmskMTkyLjE2OC4yMDIuMC8yNC8w:192.168.202.0/24/default",
        "network": "192.168.202.0/24",
        "network_view": "default"
    }
]
```

And a negative one:

```
# curl -u admin:infoblox https://192.168.201.2/wapi/v2.0/network
curl: (60) SSL certificate problem: self signed certificate
```

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) *year* *your name*

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
