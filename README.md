# SmartProxyDnsInfoblox

*Introduction here*

This plugin adds a new DNS provider for managing records in MyService.

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins.

Example, create the file `/usr/share/foreman-proxy/bundler.d/dns_infoblox.rb` with

```ruby
gem 'smart_proxy_dns_infoblox'
gem 'infoblox'
```

This plugin is compatible with Smart Proxy 1.11 or higher.

## Configuration

To enable this DNS provider, edit `/etc/foreman-proxy/settings.d/dns.yml` and set:

    :use_provider: dns_infoblox

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dns_infoblox.yml` and include:

* example_setting:

```yaml
---
#
# Configuration file for 'infoblox dns provider
#

:enabled: true
:infoblox_user: "API_user"
:infoblox_pw: "xxxxxxxxxxxxxxxxxxxxxxx"
:infoblox_host: "ipam.example.com"
```

For security reasons, you should set owner and mode like this:

```
chown root:foreman-proxy /etc/foreman-proxy/settings.d/dns_infoblox.yml 
chmod 640 /etc/foreman-proxy/settings.d/dns_infoblox.yml 
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

