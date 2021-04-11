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
repo_name                = params['repo_name']
repo_type                = params['repo_type']
branch_name              = params['branch_name']
stage_name               = params['stage_name']
commit_message           = params['commit_message']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')
require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_pipeline_utils')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password, base64_cacert, insecure_https)
  result = client.promote_pipeline_to_stage(workspace, repo_name, repo_type, branch_name, stage_name, commit_message)
rescue => e
  result[:_error] = {
    msg: "Task failed: #{e.message}",
    kind: 'puppetlabs-cd4pe/promote_pipeline_to_stage_error',
    details: e.class.to_s,
  }
  exitcode = 1
end

puts result.to_json
exit exitcode
