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
repo_branch              = params['repo_branch']
repo_name                = params['repo_name']
pipeline_name            = params['pipeline_name']
pipeline_type            = params['pipeline_type']


uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?
pipeline_name ||= repo_branch
web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
exitcode = 0
result = {}
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  pipeline_res = client.create_pipeline(workspace, pipeline_name, repo_name, repo_branch, pipeline_type)
  if pipeline_res.code != '200'
    raise "Error while adding pipeline: #{pipeline_res.body}"
  end
  puts "Added #{pipeline_type} pipeline: #{pipeline_name} for repo: #{repo_name}"
  result = pipeline_res.body
rescue => e
  result[:_error] = { msg: e.message,
                      kind: "puppetlabs-cd4pe/create_pipeline_error",
                      details: e.class.to_s }
  exitcode = 1
end
puts result.to_json
exit exitcode
