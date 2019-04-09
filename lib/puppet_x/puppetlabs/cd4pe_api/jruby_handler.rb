require 'puppet_x/puppetlabs/cd4pe_api'

# NOTE: This class is only usable when called from a JRuby instance managed
# by Puppet Server.
require 'java'
require 'singleton'

require 'puppet/server/network/http/handler'
require 'puppet_x/puppetlabs/cd4pe_api/compile_handler'

# Hooks up the route between jruby and puppet
class PuppetX::Puppetlabs::CD4PEApi::JRubyHandler
  include Puppet::Server::Network::HTTP::Handler
  include Singleton

  def initialize
    route_path = %r{^#{Puppet::Network::HTTP::MASTER_URL_PREFIX}/v3/cd4pe/compile/[^/]+$}

    diff_handler = Puppet::Network::HTTP::Route.path(route_path)
                                               .get(PuppetX::Puppetlabs::CD4PEApi::CompileHandler.new)

    register([diff_handler])
  end

  def handle(request)
    response = {}
    process(request, response)

    com.puppetlabs.puppetserver.JRubyPuppetResponse.new(
      response[:status],
      response[:body],
      response[:content_type],
      response['X-Puppet-Version'],
    )
  end
end
