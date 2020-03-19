#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'
require 'puppet/network/http_pool'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
http_server   = params['resolvable_hostname'] || Puppet[:certname]
http_port     = params['http_port']
use_ssl       = params['use_ssl']       || false
test_path     = params['test_path']     || '/'
expected_code = params['expected_code'] || 200
verify_peer   = params['verify_peer']   || true

# derived from https://github.com/voxpupuli/puppet-healthcheck/blob/master/lib/puppet_x/puppet-community/http_validator.rb
# and .../puppet/provider/http_conn_validator/http_conn_validator.rb

timeout = 30
try_sleep = 5

# Utility method; attempts to make an http/https connection to a server.
# This is abstracted out into a method so that it can be called multiple times
# for retry attempts.
#
# @return true if the connection is successful, false otherwise.
class HttpValidator
  attr_reader :http_server
  attr_reader :http_port
  attr_reader :use_ssl
  attr_reader :test_path
  attr_reader :test_headers
  attr_reader :expected_code
  attr_reader :verify_peer

  def initialize(http_server, http_port, use_ssl, test_path, expected_code, verify_peer)
    @http_server   = http_server
    @http_port     = http_port
    @use_ssl       = use_ssl
    @test_path     = test_path
    @test_headers  = { 'Accept' => 'application/json' }
    @expected_code = expected_code
    @verify_peer   = verify_peer
  end

  def attempt_connection
    conn = Puppet::Network::HttpPool.http_instance(http_server, http_port, use_ssl, verify_peer)

    response = conn.get(test_path, test_headers)
    unless response.code.to_i == expected_code
      Puppet.notice "Unable to connect to the server or wrong HTTP code (expected #{expected_code}) (http#{use_ssl ? 's' : ''}://#{http_server}:#{http_port}): [#{response.code}] #{response.msg}"
      return false
    end
    return true
  rescue StandardError => e
    Puppet.notice "Unable to connect to the server (http#{use_ssl ? 's' : ''}://#{http_server}:#{http_port}): #{e.message}"
    return false
  end
end

validator = HttpValidator.new(
  http_server,
  http_port,
  use_ssl,
  test_path,
  expected_code,
  verify_peer
)

exitcode = 0
result = {}

begin
  start_time = Time.now

  success = validator.attempt_connection

  while success == false && ((Time.now - start_time) < timeout)
    # It can take several seconds for an HTTP  service to start up;
    # especially on the first install.  Therefore, our first connection attempt
    # may fail.  Here we have somewhat arbitrarily chosen to retry every 2
    # seconds until the configurable timeout has expired.
    Puppet.notice("Failed to make an HTTP connection; sleeping #{try_sleep} seconds before retry")
    sleep try_sleep
    success = validator.attempt_connection
  end

  if success
    Puppet.debug("Connected to the host in #{Time.now - start_time} seconds.")
  else
    Puppet.notice("Failed to make an HTTP connection within timeout window of #{timeout} seconds; giving up.")
    raise "Unable to connect to the HTTP server! (#{@validator.http_server}:#{@validator.http_port} with HTTP code #{@validator.expected_code})"
  end

  result[:success] = true
rescue => e
  result[:_error] = {
    msg: "Task failed: #{e.message}",
    kind: 'puppetlabs-cd4pe/test_connection_error',
    details: e.class.to_s,
  }
  exitcode = 1
end

puts result.to_json
exit exitcode
