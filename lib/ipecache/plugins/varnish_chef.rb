require 'ipecache/plugins/plugin'

module Ipecache
  module Plugins
    class VarnishChef < Plugin
      name :varnishchef
      hooks :proxy_purge

      def perform
        safe_require 'chef'
        safe_require 'uri'

        knife_file = config.knife_config || ""
        chef_search = config.chef_search
        port = config.varnish_port || 80

        if knife_file.empty?
          plugin_puts "No knife config file specified. Exiting..."
          exit 1
        elsif File.exists?(knife_file)
          Chef::Config.from_file(knife_file)
          rest_api = Chef::REST.new(Chef::Config[:chef_server_url])
        else
          plugin_puts "Knife config file #{knife_file} doesn't exist."
          exit 1
        end

        if !chef_search
          plugin_puts "Chef role not specified, Exiting..."
          exit 1
        end

        puts ""
        plugin_puts "Beginning URL Purge from Varnish..."
        plugin_puts "Finding Varnish Servers..."
        nodes_varnish_fqdns = []
        nodes_varnish = rest_api.get_rest("/search/node?q=#{chef_search}" )
        nodes_varnish["rows"].each do |n|
          nodes_varnish_fqdns <<  n.fqdn unless n.nil?
        end

        urls.each do |u|
          url = u.chomp
          plugin_puts ("Purging #{url}")
          nodes_varnish_fqdns.each do |varnish|
            hostname = URI.parse(url).host
            path = URI.parse(url).path
            result = `curl -X BAN -s -o /dev/null -w \"%{http_code}\" --header \"Host: #{hostname}\" \"http://#{varnish}:#{port}#{path}\"`
            if result.include?("200")
              plugin_puts "--Purged from #{varnish} sucessfully"
            elsif result.include?("404")
              plugin_puts "--Purge from #{varnish} not needed, asset not found"
            else
              plugin_puts "--Purge from #{varnish} failed"
            end

          end
        end
      end
    end
  end
end
