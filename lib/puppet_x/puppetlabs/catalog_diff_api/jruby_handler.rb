require 'puppet_x/puppetlabs/catalog_diff_api'

# NOTE: This class is only usable when called from a JRuby instance managed
# by Puppet Server.
require 'java'
require 'singleton'

require 'puppet/server/network/http/handler'
require 'puppet_x/puppetlabs/catalog_diff_api/diff_handler'

class PuppetX::Puppetlabs::DiffApi::JRubyHandler
  include Puppet::Server::Network::HTTP::Handler
  include Singleton


  def initialize
    route_path = %r{^#{Puppet::Network::HTTP::MASTER_URL_PREFIX}/v3/diff-catalog/[^/]+$}

    diff_handler = Puppet::Network::HTTP::Route.path(route_path).
      get(PuppetX::Puppetlabs::DiffApi::DiffHandler.new)

    register([diff_handler])
  end

  def handle(request)
    response = {}
    process(request, response)

    com.puppetlabs.puppetserver.JRubyPuppetResponse.new(
        response[:status],
        response[:body],
        response[:content_type],
        response["X-Puppet-Version"])
  end
end
