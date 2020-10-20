#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['email']
password                 = params['password']
base64_cacert            = params['base64_cacert']
insecure_https           = params['insecure_https'] || false
workspace                = params['workspace']
repo_name                = params['repo_name']
repo_type                = params['repo_type']
branch_name              = params['branch_name']
pe_creds_name            = params['pe_creds_name']
node_group_name          = params['node_group_name']
stage_name               = params['stage_name']
add_stage_after          = params['add_stage_after']
autopromote              = params['autopromote'] || false
trigger_condition        = params['trigger_condition'] || 'AllSuccess' if autopromote

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password, base64_cacert, insecure_https)
  result = client.add_deployment_to_stage(workspace,
                                          repo_name,
                                          repo_type,
                                          branch_name,
                                          pe_creds_name,
                                          node_group_name,
                                          stage_name,
                                          add_stage_after,
                                          autopromote,
                                          trigger_condition)
rescue => e
  result[:_error] = {
    msg: "Task failed: #{e.message}",
    kind: 'puppetlabs-cd4pe/add_deployment_to_stage_error',
    details: e.class.to_s,
  }
  exitcode = 1
end
puts result.to_json
exit exitcode
