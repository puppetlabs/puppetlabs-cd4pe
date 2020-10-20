#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
base64_cacert            = params['base64_cacert']
insecure_https           = params['insecure_https'] || false
username                 = params['root_email']
password                 = params['root_password']
client_id                = params['client_id']
client_secret            = params['client_secret']
provider                 = params['provider']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password, base64_cacert, insecure_https)
  res = client.add_oauth_integration(provider, client_id, client_secret)
  if res.code != '200'
    raise "Error while adding VCS integration: #{res.body}"
  end
  puts "Added VCS integration for #{provider}"
rescue => e
  puts({ status: 'failure', error: e.message }.to_json)
  exitcode = 1
end
exit exitcode
