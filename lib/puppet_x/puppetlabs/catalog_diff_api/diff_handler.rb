require 'puppet_x/puppetlabs/catalog_diff_api'

require 'pp'

# Stub handler. Simply echoes request map in a pretty-printed format.
class PuppetX::Puppetlabs::DiffApi::DiffHandler
  def call(request, response)
    dump = PP.pp(request, '')

    response.respond_with(200, 'text/plain', "Request dump:\n#{dump}")
  end
end
