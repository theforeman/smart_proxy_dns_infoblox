# Smart Proxy DNS plugin template

This repo is an example plugin which you can use as a starting point for developing
your own DNS provider plugin for the Smart Proxy.

## Getting Started

First, clone this repo to a directory named for your new plugin

    git clone https://github.com/theforeman/smart_proxy_dns_plugin_template smart_proxy_dns_my_plugin

Now use the provided script to rewrite all the files in the plugin

    cd smart_proxy_dns_my_plugin
    ./rename.rb smart_proxy_dns_my_plugin

The script will output the required Bundler line to add the plugin to the Smart Proxy.
Apply this change, and restart the Smart Proxy to load it.

Once working, update the README.md with appropriate information, and publish your plugin!

## Getting help

The Foreman developers IRC channel and mailing list are the best places to get help:

* Freenode: #theforeman-dev
* Google Groups: foreman-dev@googlegroups.com

## Copyright

Copyright (c) 2015 Red Hat

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
