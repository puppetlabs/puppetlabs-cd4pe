require 'spec_helper'
require 'webmock/rspec'
require_relative '../../../../lib/puppet_x/puppetlabs/cd4pe_client'
require_relative '../../../../lib/puppet_x/puppetlabs/cd4pe_pipeline_utils'

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

  describe 'add_repo' do
    context 'add a github control repo to a workspace'
      include_context 'cd4pe login'
      include_context 'github repo details'
      let(:repo_name) { 'test-control-repo' }
      it 'creates a github repo' do
        stub_request(:get, workspace_url)
          .with(query: { op: 'ListSourceOrgs', provider: repo_provider }, headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(source_orgs))
          .times(1)

        stub_request(:get, workspace_url)
        .with(query: { op: 'SearchSourceRepos', provider: repo_provider, org: source_repo_owner, search: matched_source_repo_name })
        .to_return(body: JSON.generate(source_repos))
        .times(1)

        stub_request(:post, workspace_url)
          .with(body:
            {
                op: 'CreateControlRepo',
                content: {
                    name: repo_name,
                    srcRepoDisplayName: source_repo_display_name,
                    srcRepoDisplayOwner: source_repo_display_owner,
                    srcRepoId: source_repo_id,
                    srcRepoName: matched_source_repo_name,
                    srcRepoOwner: source_repo_owner,
                    srcRepoProvider: repo_provider.upcase,
                }
              })
          .to_return(body: JSON.generate(created_repo))
          .times(1)

        client = described_class.new(test_host, req_login[:content][:email], req_login[:content][:passwd])
        result = client.add_repo(
          test_workspace,
          repo_provider,
          source_repo_owner,
          matched_source_repo_name,
          repo_name,
          'control',
        )
        expect(JSON.parse(result.body, symbolize_names: true)).to eq(created_repo)
      end
    end
end
