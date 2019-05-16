#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

require 'puppet_x/puppetlabs/cd4pe_client'

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['email']
password                 = params['password']
creds_name               = params['creds_name']
pe_username              = params['pe_username']
pe_password              = params['pe_password']
pe_token                 = params['pe_token']
pe_console_host          = params['pe_console_host']

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  res = client.discover_pe_credentials(creds_name, pe_username, pe_password, pe_token, pe_console_host)
  if res.code != '200'
    raise "Error while discovering Puppet Enterprise credentials: #{res.body}"
  end
  puts "Added Puppet Enterprise credentials: #{creds_name}"
rescue => e
  puts({ status: 'failure', error: e.message }.to_json)
  exitcode = 1
end
exit exitcode
