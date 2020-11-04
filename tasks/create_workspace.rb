#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname  = params['resolvable_hostname'] || Puppet[:certname]
base64_cacert            = params['base64_cacert']
insecure_https           = params['insecure_https'] || false
email     = params['email']
password  = params['password']
username  = params['username']
workspace = params['workspace']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, email, password, base64_cacert, insecure_https)
  result = client.create_workspace(workspace, username)

  if result.code != '200'
    raise "Error while creating workspace: #{result.body}"
  end

  puts "Created workspace: #{workspace}"
  result[:success] = true
rescue => e
  result[:_error] = {
    msg: "Task failed: #{e.message}",
    kind: 'puppetlabs-cd4pe/create_workspace_error',
    details: e.class.to_s,
  }
  exitcode = 1
end

puts result.to_json
exit exitcode
