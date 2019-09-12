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
pe_creds_name            = params['pe_creds_name']
node_group_name          = params['node_group_name']
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

  puppet_environment_res = client.list_puppet_environments(workspace, pe_creds_name)
  puppet_environments = JSON.parse(puppet_environment_res.body, symbolize_names: true)
  matched_environments = puppet_environments.select{ |env| env[:name] == node_group_name }
  puts matched_environments
  raise Puppet::Error, "Aborting.. Could not find node group for name: #{node_group_name}" if matched_environments.empty?
  raise Puppet::Error, "Aborting.. Found multiple node groups for name: #{node_group_name}. Assign the node groups unique names and try again." if matched_environments.length > 1
  environment = matched_environments[0]
  new_deployment = {
    peModuleDeploymentTemplate: {
      settings: {
        doCodeDeploy: true,
        environment: {
          #TODO: Find out if this is safe to use in all cases
          nodeGroupBranch: environment[:environment],
          nodeGroupId: environment[:id],
          nodeGroupName: environment[:name],
          peCredentialsId: {
            domain: current_pipeline[:projectId][:domain],
            name: pe_creds_name,
          }
       },
       moduleId: {
          #TODO: Find out if this is the best place to source domain
         domain: current_pipeline[:projectId][:domain],
         name: repo_name,
       },
      }
    }
  }
  new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_deployment, stage_name, add_stage_after, autopromote, trigger_condition)
  new_pipeline_res = client.upsert_pipeline_stages(workspace, repo_name, repo_type, pipeline_id, new_stages)
  result = JSON.parse(new_pipeline_res.body, symbolize_names: true)
rescue => e
  result[:_error] = { msg: e.message,
    kind: "puppetlabs-cd4pe/add_deployment_to_stage_error",
    details: e.class.to_s }
  exitcode = 1
end
puts result.to_json
exit exitcode