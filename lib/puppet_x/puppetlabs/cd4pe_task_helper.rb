require 'puppet_x'
require_relative 'cd4pe_pipeline_utils'
# Provides a set of helper methods to perform more complex CD4PE workflows
module CD4PETaskHelper
  def self.add_deployment_to_stage(client,
                                   workspace,
                                   repo_name,
                                   repo_type,
                                   branch_name,
                                   pe_creds_name,
                                   node_group_name,
                                   stage_name,
                                   add_stage_after,
                                   autopromote,
                                   trigger_condition)
    current_pipeline = get_pipeline_for_branch(client, workspace, repo_name, repo_type, branch_name)
    puppet_environment_res = client.list_puppet_environments(workspace, pe_creds_name)
    puppet_environments = JSON.parse(puppet_environment_res.body, symbolize_names: true)
    matched_environments = puppet_environments.select { |env| node_group_name.casecmp(env[:name]).zero? }
    if matched_environments.empty?
      raise Puppet::Error, "Could not find node group for name: #{node_group_name}"
    end
    if matched_environments.length > 1
      raise Puppet::Error, "Found multiple node groups for name: #{node_group_name}. Assign the node groups unique names and try again."
    end
    environment = matched_environments[0]
    new_deployment = {
      peModuleDeploymentTemplate: {
        settings: {
          doCodeDeploy: true,
          environment: {
            nodeGroupBranch: environment[:environment],
            nodeGroupId: environment[:id],
            nodeGroupName: environment[:name],
            peCredentialsId: {
              domain: current_pipeline[:projectId][:domain],
              name: pe_creds_name,
            },
          },
          moduleId: {
            domain: current_pipeline[:projectId][:domain],
            name: repo_name,
          },
        },
      },
    }
    new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_deployment, stage_name, add_stage_after, autopromote, trigger_condition)
    new_pipeline_res = client.upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], new_stages)
    JSON.parse(new_pipeline_res.body, symbolize_names: true)
  end

  def self.add_job_to_stage(client,
                            workspace,
                            repo_name,
                            repo_type,
                            branch_name,
                            job_name,
                            stage_name,
                            add_stage_after,
                            autopromote,
                            trigger_condition)
    current_pipeline = get_pipeline_for_branch(client, workspace, repo_name, repo_type, branch_name)
    job_template_res = client.list_job_templates(workspace)
    job_templates = JSON.parse(job_template_res.body, symbolize_names: true)

    matched_job_templates = job_templates[:rows].select { |template| job_name.casecmp(template[:name]).zero? }
    if matched_job_templates.empty?
      raise Puppet::Error, "Could not find job for name: #{job_name}"
    end
    if matched_job_templates.length > 1
      raise Puppet::Error, "Found multiple jobs for name: #{job_name}. Give the job a unique name and try again."
    end
    new_job_destination = { vmJobTemplateId: matched_job_templates[0][:id] }
    new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_job_destination, stage_name, add_stage_after, autopromote, trigger_condition)
    new_pipeline_res = client.upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], new_stages)
    JSON.parse(new_pipeline_res.body, symbolize_names: true)
  end

  def self.add_pr_gate_to_stage(client, workspace, repo_name, repo_type, branch_name, stage_name)
    current_pipeline = get_pipeline_for_branch(client, workspace, repo_name, repo_type, branch_name)
    current_stages = current_pipeline[:stages]
    existing_stage_idx = CD4PEPipelineUtils.get_stage_index_by_name(current_stages, stage_name)
    current_stages[existing_stage_idx][:pipelineGate] = {
      projectPipelineGateType: 'PULLREQUEST',
      stageNum: current_stages[existing_stage_idx][:stageNum],
    }
    if current_stages[existing_stage_idx].key?(:triggerOn)
      current_stages[existing_stage_idx][:pipelineGate][:triggerOn] = current_stages[existing_stage_idx][:triggerOn]
    end
    if current_stages[existing_stage_idx].key?(:triggerCondition)
      current_stages[existing_stage_idx][:pipelineGate][:triggerCondition] = current_stages[existing_stage_idx][:triggerCondition]
    end

    client.upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], current_stages)
    pr_build_triggers = ['Commit', 'PullRequest']
    build_trigger_res = client.set_pipeline_auto_build_triggers(workspace, repo_name, repo_type, current_pipeline[:id], current_pipeline[:name], pr_build_triggers)
    client.set_is_build_pr_allowed(workspace, repo_name, repo_type, false)
    JSON.parse(build_trigger_res.body, symbolize_names: true)
  end
  private_class_method def self.get_pipeline_for_branch(client, workspace, repo_name, pipeline_type, branch_name)
    pipelines_by_name_res = client.list_pipelines_by_name(workspace, repo_name, pipeline_type, branch_name)
    puts pipelines_by_name_res
    pipelines_by_name = JSON.parse(pipelines_by_name_res.body, symbolize_names: true)
    matched_pipelines = pipelines_by_name.select { |pipeline| branch_name.casecmp(pipeline[:name]).zero? }
    if matched_pipelines.empty?
      raise Puppet::Error, "Could not find pipeline for #{pipeline_type} repository: #{repo_name} with branch name: #{branch_name}."
    end
    if matched_pipelines.length > 1
      raise Puppet::Error, "Found multiple pipelines for #{pipeline_type} repository: #{repo_name} with branch name: #{branch_name}."
    end
    matched_pipelines[0]
  end
end
