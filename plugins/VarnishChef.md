VarnishChef
========
Queries chef for nodes in the specified role and purges the URL list from each Varnish server

Gem Requirements
----------------
This plugin requires the following gems:

```ruby
gem 'chef'
```

Hooks
-----
- `proxy_purge`

Configuration
-------------
```yaml
plugins:
  atschef:
    knife_config: /my/.chef/knife.rb
    chef_role: Varnish
```

#### knife_config
This is the knife.rb that ipecache can use to search against your Chef server

- Type: `String`

#### chef_role
This is the chef role which your Varnish servers live in

- Type: `String`
