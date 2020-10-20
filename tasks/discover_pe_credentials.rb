#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
base64_cacert            = params['base64_cacert']
insecure_https           = params['insecure_https'] || false
username                 = params['email']
password                 = params['password']
workspace                = params['workspace']
creds_name               = params['creds_name']
token_lifetime           = params['token_lifetime'] || '180d'
pe_username              = params['pe_username']
pe_password              = params['pe_password']
pe_token                 = params['pe_token']
pe_console_host          = params['pe_console_host']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password, base64_cacert, insecure_https)
  res = client.discover_pe_credentials(workspace, creds_name, pe_username, pe_password, pe_token, pe_console_host, token_lifetime)
  if res.code != '200'
    raise "Error while discovering Puppet Enterprise credentials: #{res.body}"
  end
  puts "Added Puppet Enterprise credentials: #{creds_name}"
  result[:success] = true
rescue => e
  result[:_error] = { msg: e.message,
                      kind: 'puppetlabs-cd4pe/discover_pe_credentials_error',
                      details: e.class.to_s }
  exitcode = 1
end
puts result.to_json
exit exitcode
