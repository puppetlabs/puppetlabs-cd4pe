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
control_repo_branch      = params['control_repo_branch']
control_repo_name        = params['control_repo_name']

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
control_repo_name ||= source_repo_name
exitcode = 0
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  pipeline_res = client.create_pipeline(control_repo_branch, control_repo_name, control_repo_branch)
  if pipeline_res.code != '200'
    raise "Error while adding pipeline: #{pipeline_res.body}"
  end
  puts "Added pipeline: #{control_repo_branch} for control repo: #{control_repo_name}"
rescue => e
  puts({ status: 'failure', error: e.message }.to_json)
  exitcode = 1
end
exit exitcode
