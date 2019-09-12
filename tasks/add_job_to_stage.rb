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
job_template_name        = params['job_template_name']
stage_name               = params['stage_name']
add_stage_after          = params['add_stage_after']
autopromote              = params['autopromote'] || false
trigger_condition        = params['trigger_condition'] || 'AllSuccess' if autopromote



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
  job_template_res = client.list_job_templates(workspace)
  job_templates = JSON.parse(job_template_res.body, symbolize_names: true)

  matched_job_templates = job_templates[:rows].select{ |template| template[:name] == job_template_name }
  raise Puppet::Error, "Aborting.. Could not find job template for name: #{job_template_name}" if matched_job_templates.empty?
  raise Puppet::Error, "Aborting.. Found multiple job templates for name: #{job_template_name}. Give the job template a unique name and try again." if matched_job_templates.length > 1
  new_job_destination = { vmJobTemplateId: matched_job_templates[0][:id] }
  new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_job_destination, stage_name, add_stage_after, autopromote, trigger_condition)
  new_pipeline_res = client.upsert_pipeline_stages(workspace, repo_name, repo_type, pipeline_id, new_stages)
  result = JSON.parse(new_pipeline_res.body, symbolize_names: true)
rescue => e
  result[:_error] = { msg: e.message,
    kind: "puppetlabs-cd4pe/add_job_to_stage_error",
    details: e.class.to_s }
  exitcode = 1
end
puts result.to_json
exit exitcode