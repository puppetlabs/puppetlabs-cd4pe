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
repo_name                = params['repo_name']
repo_type                = params['repo_type']
pipeline_id              = params['pipeline_id']
stage_name               = params['stage_name']

require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_client')
require_relative File.join(params['_installdir'], 'cd4pe', 'lib', 'puppet_x', 'puppetlabs', 'cd4pe_pipeline_utils')


uri = URI.parse(hostname)
hostname = "http://#{hostname}" if uri.scheme.nil?

web_ui_endpoint = params['web_ui_endpoint'] || "#{hostname}:8080"

exitcode = 0
result = {}

begin
  client = PuppetX::Puppetlabs::CD4PEClient.new(web_ui_endpoint, username, password)
  current_pipeline_res = client.get_pipeline(workspace, repo_name, repo_type, pipeline_id)
  current_pipeline = JSON.parse(current_pipeline_res.body, symbolize_names: true)
  current_stages = current_pipeline[:stages]
  existing_stage_idx = CD4PEPipelineUtils.get_stage_index_by_name(current_stages, stage_name)
  current_stages[existing_stage_idx][:pipelineGate] = {
    projectPipelineGateType: "PULLREQUEST",
    stageNum: current_stages[existing_stage_idx][:stageNum],
  }
  #TODO: Find a better way to do conditional assignment here
  current_stages[existing_stage_idx][:pipelineGate][:triggerOn] = current_stages[existing_stage_idx][:triggerOn]  if current_stages[existing_stage_idx].key?(:triggerOn)
  current_stages[existing_stage_idx][:pipelineGate][:triggerCondition] = current_stages[existing_stage_idx][:triggerCondition] if current_stages[existing_stage_idx].key?(:triggerCondition)

  new_pipeline_res = client.upsert_pipeline_stages(workspace, repo_name, repo_type, pipeline_id, current_stages)
  pr_build_triggers = ['Commit', 'PullRequest']
  build_trigger_res = client.set_pipeline_auto_build_triggers(workspace, repo_name, repo_type, pipeline_id, current_pipeline[:name], pr_build_triggers)
  result[:pipeline] = JSON.parse(build_trigger_res.body, symbolize_names: true)
  set_is_build_pr_allowed_res = client.set_is_build_pr_allowed(workspace, repo_name, repo_type, false)


rescue => e
  result[:_error] = { msg: e.message,
    kind: "puppetlabs-cd4pe/add_pr_gate_to_stage_error",
    details: e.class.to_s }
  exitcode = 1
end

puts result.to_json
exit exitcode