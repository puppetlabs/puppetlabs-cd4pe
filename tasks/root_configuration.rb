#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'
require 'open3'

# Need to append LOAD_PATH
Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

require 'puppet_x/puppetlabs/cd4pe_client'

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['root_email']
password                 = params['root_password']

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

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
ssl_endpoint              = params['ssl_endpoint']
ssl_port                  = params['ssl_port'] || 8443

def set_ssl_web_ui_endpoint(_web_ui_endpoint, ssl_endpoint, ssl_port)
  "#{ssl_endpoint}:#{ssl_port}"
end

def all_ssl_params_provided(ssl_enabled, ssl_server_certificate, ssl_authority_certificate, ssl_server_private_key)
  !ssl_enabled.nil? && !ssl_server_certificate.nil? && !ssl_authority_certificate.nil? && !ssl_server_private_key.nil?
end

def any_ssl_params_provided(ssl_enabled, ssl_server_certificate, ssl_authority_certificate, ssl_server_private_key)
  !ssl_enabled.nil? || !ssl_server_certificate.nil? || !ssl_authority_certificate.nil? || !ssl_server_private_key.nil?
end

def ssl_enabled_requirements_satisfied(ssl_port, ssl_endpoint)
  !ssl_port.nil? && !ssl_endpoint.nil?
end

def restart_cd4pe
  restart_command = 'service docker-cd4pe restart || true'
  puts 'restarting cd4pe...'
  system_output, status = Open3.capture2e(restart_command)
  unless status.exitstatus.zero?
    raise "Critical Failure on cd4pe container restart: #{system_output}"
  end
  puts 'cd4pe successfully restarted!'
end

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  restart_after_configuration = false
  res = client.save_storage_settings(provider, endpoint, bucket, prefix, access_key, secret_key)

  if res.code != '200'
    raise "Error while saving storage settings: #{res.body}"
  end

  if all_ssl_params_provided(ssl_enabled, ssl_server_certificate, ssl_authority_certificate, ssl_server_private_key)
    if ssl_enabled
      if ssl_enabled_requirements_satisfied(ssl_port, ssl_endpoint)
        set_ssl_web_ui_endpoint(web_ui_endpoint, ssl_endpoint, ssl_port)
      else
        raise 'ssl_endpoint and ssl_port must be specified if ssl_enabled == true'
      end
    end

    res = client.save_ssl_settings(ssl_authority_certificate, ssl_server_certificate, ssl_server_private_key, ssl_enabled)

    if res.code != '200'
      raise "Error while saving ssl settings: #{res.body}"
    end

    restart_after_configuration = true
  elsif any_ssl_params_provided(ssl_enabled, ssl_server_certificate, ssl_authority_certificate, ssl_server_private_key)
    raise 'To enable SSL, the following must be specified: ssl_enabled, ssl_server_certificate, ssl_authority_certificate, ssl_server_private_key.'
  end

  res = client.save_endpoint_settings(web_ui_endpoint, backend_service_endpoint, agent_service_endpoint)

  if res.code != '200'
    raise "Error while saving endpoint settings: #{res.body}"
  end

  if restart_after_configuration
    restart_cd4pe
  end

  puts "Configuration complete! Navigate to #{web_ui_endpoint} to upload your CD4PE license and create your first user account."

  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
