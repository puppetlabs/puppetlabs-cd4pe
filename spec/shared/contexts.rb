RSpec.shared_context 'cd4pe login' do
  let(:test_host) { 'http://puppet.test' }
  let(:login_url) { "#{test_host}/login" }
  let(:hw_config_url) { "#{test_host}/root/hw-config" }
  let(:workspace_url) { "#{test_host}/carlsCoolWorkspace/ajax" }
  let(:res_cookie) do
    'com.puppet.pipelines.pfi.sid='\
    'ARVyw81QfSnwTXd1DI8ml3b93SIYSD85XWU2Ymg-wZ_tYrc8SnLz3mK5z0EQRc2NNWCaJeaZWFByCE3-VD4gSCvLnfUSjUuVO9f6HbRT5lbZHUiIn91fMocUVLHJ831rXQ==;Path=/;HttpOnly'
  end
  let(:req_cookie) do
    'com.puppet.pipelines.pfi.sid='\
    'ARVyw81QfSnwTXd1DI8ml3b93SIYSD85XWU2Ymg-wZ_tYrc8SnLz3mK5z0EQRc2NNWCaJeaZWFByCE3-VD4gSCvLnfUSjUuVO9f6HbRT5lbZHUiIn91fMocUVLHJ831rXQ=='
  end
  let(:req_login) do
    {
      op: 'PfiLogin',
      content: {
        email: 'test@test.com',
        passwd: 'test',
      },
    }
  end
  let(:res_login) do
    {
      success: true,
      username: 'root',
      domain: 'd1',
      redirectTo: '/root',
    }
  end

  before(:each) do
    stub_request(:post, login_url)
      .with(body: JSON.generate(req_login))
      .to_return(headers: { 'Set-Cookie' => res_cookie }, body: JSON.generate(res_login))
  end
end

RSpec.shared_context 'a 2 stage module pipeline' do
  let(:test_module_pipeline_name) { 'module_deployments_src' }
  let(:test_pipeline_id) { '1riocypice7pm0nko4reah1q9v' }
  let(:test_module_repo_name) { 'puppetlabs-cd4pe_tests' }
  let(:test_workspace) { 'carlsCoolWorkspace' }

  let(:initial_pipeline) do
    [{
      buildStage: {
        stageNum: 0,
      },
      id: '1riocypice7pm0nko4reah1q9v',
      name: 'module_deployments_src',
      projectId: {
        domain: 'd3',
        projectName: 'm.puppetlabs-cd4pe_tests',
      },
      sources: [
        {
          autoBuildTriggers: ['Commit'],
          branch: 'module_deployment_src',
          containerName: 'default',
          skipBuild: true,
          trigger: 'SOURCE_REPOSITORY',
        },
      ],
      stages: [
        {
          destinations: [
            {
              id: '705rtzqjy2vx04fjdswfpma8l',
              stageNum: 1,
              vmJobTemplateId: 1,
              vmJobTemplateName: 'module-pdk-validate',
            },
          ],
          stageName: 'Code Validation stage',
          stageNum: 1,
          triggerOn: false,
        },
        {
          destinations: [
            {
              id: '1oafk1z9kn53u098tth10vzowi',
              stageNum: 2,
              peModuleDeploymentTemplate: {
                baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
                settings: {
                  doCodeDeploy: true,
                  environment: {
                    nodeGroupBranch: 'production',
                    nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                    nodeGroupName: 'Production environment',
                    peCredentialsId: {
                      domain: 'd3',
                      name: 'PE-Github',
                    },
                  },
                  moduleId: {
                    domain: 'd3',
                    name: 'puppetlabs-cd4pe_tests',
                  },
                },
              },
            },
          ],
          stageNum: 2,
          stageName: 'Deployment stage',
          triggerOn: false,
        },
      ],
    }]
  end
end

RSpec.shared_context 'add a module deployment to a new stage' do
  let(:test_pe_creds_name) { 'PE-Github' }
  let(:test_node_group_name) { 'module_deployments_target' }
  let(:new_stage_name) { 'newTestStage' }
  let(:autopromote) { true }
  let(:trigger_condition) { 'AllSuccess' }
  let(:add_stage_after) { 'Code Validation stage' }

  let(:updated_stages) do
    [
      {
        destinations: [
          {
            id: '705rtzqjy2vx04fjdswfpma8l',
            stageNum: 1,
            vmJobTemplateId: 1,
            vmJobTemplateName: 'module-pdk-validate',
          },
        ],
        stageName: 'Code Validation stage',
        stageNum: 1,
        triggerOn: false,
      },
      {
        destinations: [
          {
            peModuleDeploymentTemplate: {
              settings: {
                doCodeDeploy: true,
                environment: {
                  nodeGroupBranch: 'module_deployments_target',
                  nodeGroupId: 'ac38f5d2-36b7-4ae8-a842-13aecaff6d16',
                  nodeGroupName: 'module_deployments_target',
                  peCredentialsId: {
                    domain: 'd3',
                    name: 'PE-Github',
                  },
                },
                moduleId: {
                  domain: 'd3',
                  name: 'puppetlabs-cd4pe_tests',
                },
              },
            },
          },
        ],
        stageName: new_stage_name,
        triggerOn: true,
        triggerCondition: 'AllSuccess',
      },
      {
        destinations: [
          {
            id: '1oafk1z9kn53u098tth10vzowi',
            stageNum: 2,
            peModuleDeploymentTemplate: {
              baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
              settings: {
                doCodeDeploy: true,
                environment: {
                  nodeGroupBranch: 'production',
                  nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                  nodeGroupName: 'Production environment',
                  peCredentialsId: {
                    domain: 'd3',
                    name: 'PE-Github',
                  },
                },
                moduleId: {
                  domain: 'd3',
                  name: 'puppetlabs-cd4pe_tests',
                },
              },
            },
          },
        ],
        stageNum: 2,
        stageName: 'Deployment stage',
        triggerOn: false,
      },
    ]
  end

  let(:updated_pipeline) do
    [{
      buildStage: {
        stageNum: 0,
      },
      id: '1riocypice7pm0nko4reah1q9v',
      name: 'module_deployments_src',
      projectId: {
        domain: 'd3',
        projectName: 'm.puppetlabs-cd4pe_tests',
      },
      sources: [
        {
          autoBuildTriggers: ['Commit'],
          branch: 'module_deployment_src',
          containerName: 'default',
          skipBuild: true,
          trigger: 'SOURCE_REPOSITORY',
        },
      ],
      stages: [
        {
          destinations: [
            {
              id: '705rtzqjy2vx04fjdswfpma8l',
              stageNum: 1,
              vmJobTemplateId: 1,
              vmJobTemplateName: 'module-pdk-validate',
            },
          ],
          stageName: 'Code Validation stage',
          stageNum: 1,
          triggerOn: false,
        },
        {
          destinations: [
            {
              peModuleDeploymentTemplate: {
                baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
                settings: {
                  doCodeDeploy: true,
                  environment: {
                    nodeGroupBranch: 'production',
                    nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                    nodeGroupName: 'Production environment',
                    peCredentialsId: {
                      domain: 'd3',
                      name: 'PE-Github',
                    },
                  },
                  moduleId: {
                    domain: 'd3',
                    name: 'puppetlabs-cd4pe_tests',
                  },
                },
              },
            },
          ],
          stageName: 'newTestStage',
          stageNum: 2,
          triggerOn: true,
          triggerCondition: 'AllSuccess',
        },
        {
          destinations: [
            {
              id: '1oafk1z9kn53u098tth10vzowi',
              stageNum: 3,
              peModuleDeploymentTemplate: {
                baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
                settings: {
                  doCodeDeploy: true,
                  environment: {
                    nodeGroupBranch: 'production',
                    nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                    nodeGroupName: 'Production environment',
                    peCredentialsId: {
                      domain: 'd3',
                      name: 'PE-Github',
                    },
                  },
                  moduleId: {
                    domain: 'd3',
                    name: 'puppetlabs-cd4pe_tests',
                  },
                },
              },
            },
          ],
          stageNum: 3,
          stageName: 'Deployment stage',
          triggerOn: false,
        },
      ],
    }]
  end

  let(:puppet_enterprise_environments) do
    [
      {
        classes: {},
        configData: {},
        description: 'Production nodes',
        environment: 'production',
        environmentTrumps: true,
        id: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
        name: 'Production environment',
        parent: '504f45e9-fee6-490f-b38c-cb4001eeeb95',
      },
      {
        classes: {},
        configData: {},
        description: 'Development nodes',
        environment: 'development',
        environmentTrumps: true,
        id: 'c5ad4792-12a5-4cd9-9a2a-ea3d07d384b9',
        name: 'Development environment',
        parent: '504f45e9-fee6-490f-b38c-cb4001eeeb95',
      },
      {
        classes: { cd4pe_tests: {} },
        configData: {},
        description: 'env for tests',
        environment: 'module_deployments_target',
        environmentTrumps: true,
        id: 'ac38f5d2-36b7-4ae8-a842-13aecaff6d16',
        name: 'module_deployments_target',
        parent: '504f45e9-fee6-490f-b38c-cb4001eeeb95',
        rule: ['or', ['=', 'name', 'cdpe-mod-deployment-2.delivery.puppetlabs.net']],
        variables: {},
      },
    ]
  end
end

RSpec.shared_context 'add a job to an existing stage' do
  let(:test_job_name) { 'my-test-job' }
  let(:target_stage) { 'Code Validation stage' }
  let(:autopromote) { false }
  let(:list_job_templates) do
    {
      rows: [
        {
          baseTaskUrl: 'http://localhost:8080/test-workspace1/jobs',
          configuration: {
            buildCapabilities: ['docker'],
            noDind: true,
            serverDomain: 'd3',
            vmImage: 'docker:puppet/puppet-dev-tools:latest',
            vmPull: true,
          },
          created: 1_568_836_281_849,
          creatorDomain: 'd3',
          creatorNick: 'carlsCoolWorkspace',
          description: 'Validate that a control repo\'s Puppetfile is syntactically correct',
          domain: 'd3',
          id: 6,
          manifestId: '10n4rcrf2wdp0i22fufxrynv4',
          name: 'control-repo-puppetfile-syntax-validate',
          shouldNotify: true,
        },
        {
          baseTaskUrl: 'http://localhost:8080/test-workspace1/jobs',
          configuration: {
            buildCapabilities: ['docker'],
            noDind: true,
            serverDomain: 'd3',
            vmImage: 'docker:puppet/puppet-dev-tools:latest',
            vmPull: true,
          },
          created: 1_568_836_281_849,
          creatorDomain: 'd3',
          creatorNick: 'carlsCoolWorkspace',
          description: 'Validate that a control repo\'s Puppetfile is syntactically correct',
          domain: 'd3',
          id: 42,
          manifestId: '10n4rcrf2wdp0i22fufxrynv4',
          name: test_job_name,
          shouldNotify: true,
        },
      ],
    }
  end

  let(:updated_stages) do
    [
      {
        destinations: [
          {
            id: '705rtzqjy2vx04fjdswfpma8l',
            stageNum: 1,
            vmJobTemplateId: 1,
            vmJobTemplateName: 'module-pdk-validate',
          },
          {
            vmJobTemplateId: 42,
          },
        ],
        stageName: 'Code Validation stage',
        stageNum: 1,
        triggerOn: false,
      },
      {
        destinations: [
          {
            id: '1oafk1z9kn53u098tth10vzowi',
            stageNum: 2,
            peModuleDeploymentTemplate: {
              baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
              settings: {
                doCodeDeploy: true,
                environment: {
                  nodeGroupBranch: 'production',
                  nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                  nodeGroupName: 'Production environment',
                  peCredentialsId: {
                    domain: 'd3',
                    name: 'PE-Github',
                  },
                },
                moduleId: {
                  domain: 'd3',
                  name: 'puppetlabs-cd4pe_tests',
                },
              },
            },
          },
        ],
        stageNum: 2,
        stageName: 'Deployment stage',
        triggerOn: false,
      },
    ]
  end

  let(:updated_pipeline) do
    [{
      buildStage: {
        stageNum: 0,
      },
      id: '1riocypice7pm0nko4reah1q9v',
      name: 'module_deployments_src',
      projectId: {
        domain: 'd3',
        projectName: 'm.puppetlabs-cd4pe_tests',
      },
      sources: [
        {
          autoBuildTriggers: ['Commit'],
          branch: 'module_deployment_src',
          containerName: 'default',
          skipBuild: true,
          trigger: 'SOURCE_REPOSITORY',
        },
      ],
      stages: [
        {
          destinations: [
            {
              id: '705rtzqjy2vx04fjdswfpma8l',
              stageNum: 1,
              vmJobTemplateId: 1,
              vmJobTemplateName: 'module-pdk-validate',
            },
            {
              id: 'asdf1234',
              stageNum: 1,
              vmJobTemplateId: 42,
              vmJobTemplateName: test_job_name,
            },
          ],
          stageName: 'Code Validation stage',
          stageNum: 1,
          triggerOn: false,
        },
        {
          destinations: [
            {
              id: '1oafk1z9kn53u098tth10vzowi',
              stageNum: 2,
              peModuleDeploymentTemplate: {
                baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
                settings: {
                  doCodeDeploy: true,
                  environment: {
                    nodeGroupBranch: 'production',
                    nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                    nodeGroupName: 'Production environment',
                    peCredentialsId: {
                      domain: 'd3',
                      name: 'PE-Github',
                    },
                  },
                  moduleId: {
                    domain: 'd3',
                    name: 'puppetlabs-cd4pe_tests',
                  },
                },
              },
            },
          ],
          stageNum: 2,
          stageName: 'Deployment stage',
          triggerOn: false,
        },
      ],
    }]
  end
end

RSpec.shared_context 'add a pr gate to an existing stage' do
  let(:target_stage) { 'Code Validation stage' }
  let(:auto_build_triggers) do
    ['Commit', 'PullRequest']
  end

  let(:updated_stages) do
    [
      {
        destinations: [
          {
            id: '705rtzqjy2vx04fjdswfpma8l',
            stageNum: 1,
            vmJobTemplateId: 1,
            vmJobTemplateName: 'module-pdk-validate',
          },
        ],
        pipelineGate: {
          projectPipelineGateType: 'PULLREQUEST',
          stageNum: 1,
          triggerOn: false,
        },
        stageName: 'Code Validation stage',
        stageNum: 1,
        triggerOn: false,
      },
      {
        destinations: [
          {
            id: '1oafk1z9kn53u098tth10vzowi',
            stageNum: 2,
            peModuleDeploymentTemplate: {
              baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
              settings: {
                doCodeDeploy: true,
                environment: {
                  nodeGroupBranch: 'production',
                  nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                  nodeGroupName: 'Production environment',
                  peCredentialsId: {
                    domain: 'd3',
                    name: 'PE-Github',
                  },
                },
                moduleId: {
                  domain: 'd3',
                  name: 'puppetlabs-cd4pe_tests',
                },
              },
            },
          },
        ],
        stageNum: 2,
        stageName: 'Deployment stage',
        triggerOn: false,
      },
    ]
  end

  let(:updated_pipeline) do
    [{
      buildStage: {
        stageNum: 0,
      },
      id: '1riocypice7pm0nko4reah1q9v',
      name: 'module_deployments_src',
      projectId: {
        domain: 'd3',
        projectName: 'm.puppetlabs-cd4pe_tests',
      },
      sources: [
        {
          autoBuildTriggers: ['Commit', 'PullRequest'],
          branch: 'module_deployment_src',
          containerName: 'default',
          skipBuild: true,
          trigger: 'SOURCE_REPOSITORY',
        },
      ],
      stages: [
        {
          destinations: [
            {
              id: '705rtzqjy2vx04fjdswfpma8l',
              stageNum: 1,
              vmJobTemplateId: 1,
              vmJobTemplateName: 'module-pdk-validate',
            },
          ],
          pipelineGate: {
            projectPipelineGateType: 'PULLREQUEST',
          },
          stageName: 'Code Validation stage',
          stageNum: 1,
          triggerOn: false,
        },
        {
          destinations: [
            {
              id: '1oafk1z9kn53u098tth10vzowi',
              stageNum: 2,
              peModuleDeploymentTemplate: {
                baseTaskUrl: 'http://localhost:8080/carlsCoolWorkspace/module-deployments',
                settings: {
                  doCodeDeploy: true,
                  environment: {
                    nodeGroupBranch: 'production',
                    nodeGroupId: '5499bcea-06fd-4f46-a3d9-31aeb9b69f6a',
                    nodeGroupName: 'Production environment',
                    peCredentialsId: {
                      domain: 'd3',
                      name: 'PE-Github',
                    },
                  },
                  moduleId: {
                    domain: 'd3',
                    name: 'puppetlabs-cd4pe_tests',
                  },
                },
              },
            },
          ],
          stageNum: 2,
          stageName: 'Deployment stage',
          triggerOn: false,
        },
      ],
    }]
  end
end

RSpec.shared_context 'github repo details' do
  let(:test_workspace) { 'carlsCoolWorkspace' }
  let(:repo_provider) { 'github' }
  let(:source_orgs) do
    [
      {
        orgType: 'GITHUB_ORG',
        provider: 'github',
        organization: 'puppetlabs',
        organizationDisplayName: 'puppetlabs',
        id: '234268',
        personalOrg: false,
      },
      {
        orgType: 'GITHUB_USER',
        provider: 'github',
        organization: 'Ziaunys',
        organizationDisplayName: 'Ziaunys',
        id: '1063949',
        personalOrg: true,
      },
    ]
  end
  let(:matched_source_repo_name) { 'control-repo' }
  let(:source_repo_display_name) { 'control-repo' }
  let(:source_repo_display_owner) { 'puppetlabs' }
  let(:source_repo_owner) { 'puppetlabs' }
  let(:source_repo_id) { '40554625' }

  let(:source_repos) do
    [
      {
        provider: 'github',
        org: 'puppetlabs',
        orgDisplayName: 'puppetlabs',
        orgId: '234268',
        owner: 'puppetlabs',
        ownerDisplayName: 'puppetlabs',
        ownerId: '234268',
        repoName: 'control-repo',
        repoDisplayName: 'control-repo',
        repoId: '40554625',
        isPublic: true,
        accessLevel: 'ADMIN',
      },
      {
        provider: 'github',
        org: 'puppetlabs',
        orgDisplayName: 'puppetlabs',
        orgId: '234268',
        owner: 'puppetlabs',
        ownerDisplayName: 'puppetlabs',
        ownerId: '234268',
        repoName: 'puppetlabs-pe_perf_control_repo',
        repoDisplayName: 'puppetlabs-pe_perf_control_repo',
        repoId: '179578828',
        isPublic: true,
        accessLevel: 'ADMIN',
      },
    ]
  end

  let(:created_repo) do
    {
      name: matched_source_repo_name,
      srcRepoDisplayName: source_repo_display_name,
      srcRepoDisplayOwner: source_repo_display_owner,
      srcRepoId: source_repo_id,
      srcRepoName: matched_source_repo_name,
      srcRepoOwner: source_repo_owner,
      srcRepoProvider: repo_provider.upcase,
      domain: 'd7',
    }
  end
  end