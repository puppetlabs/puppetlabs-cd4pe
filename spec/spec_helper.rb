RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

default_facts = {
  architecture: 'x86_64',
  osfamily: 'RedHat',
  platform_tag: 'el-7-x86_64',
  operatingsystem: 'CentOS',
  lsbmajdistrelease: '7',
  operatingsystemrelease: '7.1',
  operatingsystemmajrelease: '7',
  is_pe: 'true',
  pe_concat_basedir: '/tmp/file',
  platform_symlink_writable: true,
  puppetversion: '4.5.1',
  aio_agent_version: '1.5.1',
  memorysize: '1.00 GB',
  processorcount: 1,
  id: 'root',
  gid: 'root',
  path: '/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/bin',
  mountpoints: { '/' => {} },
  puppet_files_dir_present: 'false',
  os: {
    'family' => 'RedHat',
    'name'                   => 'CentOS',
    'release'                => {
      'major' => '6',
    },
  },
  pe_build: '2018.1.0',
  memory: { 'system' => { 'total_bytes' => 4_294_967_296 } },
  processors: { 'count' => 1 },
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f)))
  rescue => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

module Helpers
  def pre_condition
    <<-PRE_COND
class {'puppet_enterprise':
  certificate_authority_host   => 'ca.rspec',
  puppet_master_host           => 'master.rspec',
  console_host                 => 'console.rspec',
  puppetdb_host                => 'puppetdb.rspec',
  database_host                => 'database.rspec',
  pcp_broker_host              => 'pcp_broker.rspec',
}
PRE_COND
  end
end

module RSpec::Puppet
  # Rspec-puppet has no support sensitive params...taken from open PR here:
  # https://github.com/rodjek/rspec-puppet/pull/464/files
  # A wrapper representing Sensitive data type, eg. in class params.
  class Sensitive
    # Create a new Sensitive object
    # @param [Object] value to wrap
    def initialize(value)
      @value = value
    end

    # @return the wrapped value
    def unwrap
      @value
    end

    # @return true
    def sensitive?
      true
    end

    # @return inspect of the wrapped value, inside Sensitive()
    def inspect
      "Sensitive(#{@value.inspect})"
    end

    # Check for equality with another value.
    # If compared to Puppet Sensitive type, it compares the wrapped values.

    # @param other [#unwrap, Object] value to compare to
    def ==(other)
      if other.respond_to? :unwrap
        unwrap == other.unwrap
      else
        super
      end
    end
  end
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.include Helpers, RSpec::Puppet::Sensitive
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
  end
end

def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last_module, next_module|
    last_module.const_set(next_module, Module.new) unless last_module.const_defined?(next_module, false)
    last_module.const_get(next_module, false)
  end
end

# Helper to return value wrapped in Sensitive type.
#
# @param [Object] value to wrap
# @return [RSpec::Puppet::Sensitive] a new Sensitive wrapper with the new value
def sensitive(value)
  RSpec::Puppet::Sensitive.new(value)
end

# 'spec_overrides' from sync.yml will appear below this line

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

RSpec.shared_context 'add_deployment_to_stage test params for a module deployment' do
  let(:test_module_pipeline_name) { 'module_deployments_src' }
  let(:test_pipeline_id) { '1riocypice7pm0nko4reah1q9v' }
  let(:test_module_repo_name) { 'puppetlabs-cd4pe_tests' }
  let(:test_workspace) { 'carlsCoolWorkspace' }
  let(:test_pe_creds_name) { 'PE-Github' }
  let(:test_node_group_name) { 'module_deployments_target' }
  let(:new_stage_name) { 'newTestStage'}
  let(:add_stage_after) { 'Code Validation stage' }

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
