#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname              = params['resolvable_hostname'] || Puppet[:certname]
base64_cacert         = params['base64_cacert']
insecure_https        = params['insecure_https'] || false
email                 = params['email']
username              = params['username']
password              = params['password']
first_name            = params['first_name']
last_name             = params['last_name']
company_name          = params['company_name']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
exitcode = 0
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, nil, nil, base64_cacert, insecure_https)
  res = client.create_user(email, username, password, first_name, last_name, company_name)
  if res.code != '200'
    raise "Error while creating user: #{res.body}"
  end
  puts "Created user: #{username}"
rescue => e
  puts({ status: 'failure', error: e.message }.to_json)
  exitcode = 1
end
exit exitcode
