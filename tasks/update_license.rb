#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

require 'puppet_x/puppetlabs/cd4pe_client'

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['root_email']
password                 = params['root_password']
license                  = params['license']

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  res = client.save_license(license)
  if res.code != '200'
    raise Puppet::Error "Error while saving license: #{res.body}"
  end

  puts 'License updated'

  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
