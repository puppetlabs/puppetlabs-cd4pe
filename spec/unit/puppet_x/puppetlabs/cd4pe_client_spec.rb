require 'spec_helper'
require 'webmock/rspec'
require_relative '../../../../lib/puppet_x/puppetlabs/cd4pe_client'

describe PuppetX::Puppetlabs::CD4PEClient do
  describe 'add_deployment_to_stage' do
    context 'add a module deployment to a new pipeline stage' do
      include_context 'cd4pe login'
      include_context 'a 2 stage module pipeline'
      include_context 'add a module deployment to a new stage'
      it 'returns an updated pipelines hash' do
        stub_request(:get, workspace_url)
          .with(query: { op: 'ListPipelinesByName', pipelineName: test_module_pipeline_name, moduleName: test_module_repo_name }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(initial_pipeline))
          .times(1)

        stub_request(:get, workspace_url)
          .with(query: { op: 'ListPuppetEnterpriseEnvironments', name: test_pe_creds_name }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(puppet_enterprise_environments))
          .times(1)

        stub_request(:post, workspace_url)
          .with(body: { op: 'UpsertPipelineStages', content: { pipelineId: test_pipeline_id, moduleName: test_module_repo_name, stages: updated_stages } }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(updated_pipeline))
          .times(1)

        client = described_class.new(test_host, req_login[:content][:email], req_login[:content][:passwd])
        result = client.add_deployment_to_stage(
          test_workspace,
          test_module_repo_name,
          'module',
          test_module_pipeline_name,
          test_pe_creds_name,
          test_node_group_name,
          new_stage_name,
          add_stage_after,
          autopromote,
          trigger_condition,
        )
        expect(result).to eq(updated_pipeline)
      end
    end
  end

  describe 'add_job_to_stage' do
    context 'add a job to an existing pipeline stage' do
      include_context 'cd4pe login'
      include_context 'a 2 stage module pipeline'
      include_context 'add a job to an existing stage'
      it 'returns an updated pipelines hash' do
        stub_request(:get, workspace_url)
          .with(query: { op: 'ListPipelinesByName', pipelineName: test_module_pipeline_name, moduleName: test_module_repo_name }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(initial_pipeline))
          .times(1)

        stub_request(:get, workspace_url)
          .with(query: { op: 'ListVmJobTemplates' }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(list_job_templates))
          .times(1)

        stub_request(:post, workspace_url)
          .with(body: { op: 'UpsertPipelineStages', content: { pipelineId: test_pipeline_id, moduleName: test_module_repo_name, stages: updated_stages } }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(updated_pipeline))
          .times(1)

        client = described_class.new(test_host, req_login[:content][:email], req_login[:content][:passwd])
        result = client.add_job_to_stage(
          test_workspace,
          test_module_repo_name,
          'module',
          test_module_pipeline_name,
          test_job_name,
          target_stage,
          nil,
          autopromote,
          nil,
        )
        expect(result).to eq(updated_pipeline)
      end
    end
  end

  describe 'add_pr_gate_to_stage' do
    context 'add a pr gate to an existing stage' do
      include_context 'cd4pe login'
      include_context 'a 2 stage module pipeline'
      include_context 'add a pr gate to an existing stage'
      it 'returns an updated pipelines hash' do
        stub_request(:get, workspace_url)
          .with(query: { op: 'ListPipelinesByName', pipelineName: test_module_pipeline_name, moduleName: test_module_repo_name }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(initial_pipeline))
          .times(1)

        stub_request(:post, workspace_url)
          .with(body: { op: 'UpsertPipelineStages', content: { pipelineId: test_pipeline_id, moduleName: test_module_repo_name, stages: updated_stages } }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(updated_pipeline))
          .times(1)

        stub_request(:post, workspace_url)
          .with(body:
            {
              op: 'SetPipelineAutoBuildTriggers',
              content: {
                moduleName: test_module_repo_name,
                pipelineId: test_pipeline_id,
                rule: {
                  autoBuildTriggers: auto_build_triggers,
                  branch: test_module_pipeline_name,
                },
              },
            })
          .to_return(body: JSON.generate(updated_pipeline))
          .times(1)

        stub_request(:post, workspace_url)
          .with(body: { op: 'SetIsBuildPRAllowed', content: { isBuildPRAllowed: false, moduleName: test_module_repo_name } })
          .to_return(body: JSON.generate(success: true))
          .times(1)

        client = described_class.new(test_host, req_login[:content][:email], req_login[:content][:passwd])
        result = client.add_pr_gate_to_stage(
          test_workspace,
          test_module_repo_name,
          'module',
          test_module_pipeline_name,
          target_stage,
        )
        expect(result).to eq(updated_pipeline)
      end
    end
  end
end
