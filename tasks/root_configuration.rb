#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

# Need to append LOAD_PATH
Puppet.initialize_settings
$:.unshift(Puppet[:plugindest])

require 'puppet_x/puppetlabs/cd4pe_client'

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['root_email']
password                 = params['root_password']


uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme == nil


web_ui_endpoint           = params['web_ui_endpoint'] || "#{hostname}:8080"
backend_service_endpoint  = params['backend_service_endpoint'] || "#{hostname}:8000"
agent_service_endpoint    = params['agent_service_endpoint'] || "#{hostname}:7000"
provider                  = params['storage_provider'] || :DISK
endpoint                  = params['storage_endpoint']
bucket                    = params['storage_bucket'] || 'cd4pe'
prefix                    = params['storage_prefix']
access_key                = params['s3_access_key']
secret_key                = params['s3_secret_key']
secret_key              ||= params['artifactory_access_token']
secret_key              ||= ''
ssl_enabled               = params['ssl_enabled']
ssl_server_certificate    = params['ssl_server_certificate']
ssl_authority_certificate = params['ssl_authority_certificate']
ssl_server_private_key    = params['ssl_server_private_key']

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  res = client.save_storage_settings(provider, endpoint, bucket, prefix, access_key, secret_key)
  if res.code != '200'
    raise Puppet::Error "Error while saving storage settings: #{res.body}"
  end

  res = client.save_endpoint_settings(web_ui_endpoint, backend_service_endpoint, agent_service_endpoint)

  if res.code != '200'
    raise Puppet::Error "Error while saving endpoint settings: #{res.body}"
  end

  if ssl_enabled != nil && ssl_server_certificate != nil && ssl_authority_certificate != nil && ssl_server_private_key != nil
    res = client.save_ssl_settings(ssl_authority_certificate, ssl_server_certificate, ssl_server_private_key, ssl_enabled);

    if res.code != '200'
      raise Puppet::Error "Error while saving ssl settings: #{res.body}"
    end
  end

  puts "Configuration complete! Navigate to #{web_ui_endpoint} to upload your CD4PE license and create your first user account."


  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
