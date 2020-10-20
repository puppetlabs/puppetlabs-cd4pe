#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname          = params['resolvable_hostname'] || Puppet[:certname]
base64_cacert     = params['base64_cacert']
insecure_https    = params['insecure_https'] || false
email             = params['email']
password          = params['password']
provider          = params['provider']
workspace         = params['workspace']
provider_specific = params['provider_specific']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, email, password, base64_cacert, insecure_https)
  result = client.add_vcs_integration(provider, workspace, provider_specific)

  if result.code != '200'
    raise "Error while adding VCS integration: #{result.body}"
  end

  puts "Added integration for #{provider}."
  result[:success] = true
rescue => e
  result[:_error] = {
    msg: "Task failed: #{e.message}",
    kind: 'puppetlabs-cd4pe/add_vcs_integration_error',
    details: e.class.to_s,
  }
  exitcode = 1
end

puts result.to_json
exit exitcode
