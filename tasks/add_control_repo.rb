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
repo_provider            = params['repo_provider']
repo_org                 = params['source_repo_org']
source_repo_name         = params['source_repo_name']
source_repo_branch       = params['source_repo_branch']
control_repo_name        = params['control_repo_name']

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
control_repo_name ||= source_repo_name
exitcode = 0
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  repo_res = client.add_control_repo(repo_provider, repo_org, source_repo_name, control_repo_name)
  if repo_res.code != '200'
    raise "Error while adding control repository: #{repo_res.body}"
  end
  puts "Added control repository: #{control_repo_name}"
  control_repo = JSON.parse(repo_res.body, symbolize_names: true)
  # Create the base pipeline & webhook to mimic the front-end workflow
  pipeline_res = client.create_pipeline(source_repo_branch, control_repo[:name], source_repo_branch)
  if pipeline_res.code != '200'
    raise "Error while adding pipeline: #{pipeline_res.body}"
  end
  puts "Added base pipeline: #{source_repo_branch} for control repo: #{control_repo_name}"

  webhook_res = client.post_provider_webhook(control_repo[:name], control_repo[:srcRepoOwner], control_repo[:srcRepoProvider])

  if webhook_res.code != '200'
    raise "Error while adding webhook for control repo: #{control_repo[:name]}"
  end
  puts "Added webhook for control repo: #{control_repo[:name]}"
rescue => e
  puts({ status: 'failure', error: e.message }.to_json)
  exitcode = 1
end
exit exitcode
