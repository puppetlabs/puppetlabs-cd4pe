#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'uri'

Puppet.initialize_settings
$LOAD_PATH.unshift(Puppet[:plugindest])

params = JSON.parse(STDIN.read)
hostname                 = params['resolvable_hostname'] || Puppet[:certname]
username                 = params['email']
password                 = params['password']
workspace                = params['workspace']
source_control            = params['source_control']
repo_org                 = params['source_repo_org']
source_repo_name         = params['source_repo_name']
source_repo_branch       = params['source_repo_branch']
repo_name                = params['repo_name']
repo_type                = params['repo_type']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
repo_name ||= source_repo_name
exitcode = 0
result = {}
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  repo_res = client.add_repo(workspace, source_control, repo_org, source_repo_name, repo_name, repo_type)
  if repo_res.code != '200'
    raise "Error while adding #{repo_type} repository: #{repo_res.body}"
  end
  puts "Added #{repo_type} repository: #{repo_name}"
  created_repo = JSON.parse(repo_res.body, symbolize_names: true)
  result[:repository] = created_repo
  # Create the base pipeline & webhook to mimic the front-end workflow
  pipeline_res = client.create_pipeline(workspace, repo_name, source_repo_branch, repo_type)
  if pipeline_res.code != '200'
    raise "Error while adding pipeline: #{pipeline_res.body}"
  end
  result[:pipeline] = pipeline_res.body
  puts "Added base pipeline: #{source_repo_branch} for #{repo_type} repo: #{repo_name}"
rescue => e
  result[:_error] = { msg: e.message,
                      kind: 'puppetlabs-cd4pe/add_repo_error',
                      details: e.class.to_s }
  exitcode = 1
end

begin
  client.post_provider_webhook(workspace, created_repo[:name], created_repo[:srcRepoOwner], created_repo[:srcRepoProvider])
  puts "Added webhook for #{repo_type} repo: #{created_repo[:name]}"
rescue => e
  # Just print the error but don't mark the task as failed since the repo and pipeline were created successfully
  puts "Error while adding webhook for #{repo_type} repo: #{source_repo_name}: #{e.message}"
end

puts result.to_json
exit exitcode
