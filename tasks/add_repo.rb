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
source_control           = params['source_control']
repo_org                 = params['source_repo_org']
source_repo_name         = params['source_repo_name']
source_repo_branch       = params['source_repo_branch']
pipelines_as_code_branch = params['pipelines_as_code_branch']
repo_name                = params['repo_name']
repo_type                = params['repo_type']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')
require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_task_logger')

uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?
logger = CD4PETaskLogger.new
web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"
repo_name ||= source_repo_name
exitcode = 0
result = {}
begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password, base64_cacert, insecure_https)
  repo_res = client.add_repo(workspace, source_control, repo_org, source_repo_name, repo_name, repo_type)
  if repo_res.code != '200'
    raise "Error while adding #{repo_type} repository: #{repo_res.body}"
  end
  logger.log("Added #{repo_type} repository: #{repo_name}")
  created_repo = JSON.parse(repo_res.body, symbolize_names: true)
  result[:repository] = created_repo
  # Create the base pipeline & webhook to mimic the front-end workflow if a PaC branch isn't specified
  if pipelines_as_code_branch.empty?
    pipeline_res = client.create_pipeline(workspace, repo_name, source_repo_branch, repo_type)
    if pipeline_res.code != '200'
      raise "Error while adding pipeline:\n #{pipeline_res.body}"
    end
    result[:pipeline] = JSON.parse(pipeline_res.body, symbolize_names: true)
    logger.log("Added base pipeline: #{source_repo_branch} for #{repo_type} repo: #{repo_name}")
  else
    enable_pac_res = client.set_pipelines_as_code_branch(workspace, repo_type, repo_name, pipelines_as_code_branch)
    if enable_pac_res.code != '200'
      raise "Error while enabling pipelines as code:\n #{enable_pac_res.body}"
    end
    pac_error_res = client.get_pipelines_as_code_error(workspace, repo_type, repo_name)
    pac_error = JSON.parse(pac_error_res.body, symbolize_names: true)
    if pac_error.empty?
      logger.log("Successfully enabled pipelines as code for #{repo_type} repo: #{repo_name} with branch #{pipelines_as_code_branch}")
      result[:pipelines] = JSON.parse(enable_pac_res.body, symbolize_names: true)
    else
      formatted_pac_error = "Enabled pipelines as code with validation error:\n #{pac_error}"
      logger.log(formatted_pac_error)
      result[:_error] = {
        msg: formatted_pac_error,
        kind: 'puppetlabs-cd4pe/add_repo_pac_error',
        details: { pipelines_as_code_branch: pipelines_as_code_branch },
      }
    end
  end
rescue => e
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs-cd4pe/add_repo_error',
    details: e.class.to_s,
  }
  result[:logs] = logger.logs
  puts result.to_json
  exit 1
end

begin
  client.post_provider_webhook(workspace, created_repo)
  logger.log("Added webhook for #{repo_type} repo: #{created_repo[:name]}")
rescue => e
  formatted_webhook_error = "Error while adding webhook for #{repo_type} repo:\n #{source_repo_name}: #{e.message}"
  logger.log(formatted_webhook_error)
  result[:_error] = {
    msg: formatted_webhook_error,
    kind: 'puppetlabs-cd4pe/add_repo_webhook_error',
    details: {
      repo_type: repo_type,
      source_repo_name: source_repo_name,
    },
  }
end
result[:logs] = logger.logs
puts result.to_json
exit exitcode
