require 'spec_helper'

RSpec.describe 'cd4pe::root_config' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_enterprise':
        puppet_master_host           => 'master.rspec',
      }
      class {'puppet_enterprise::profile::master':}
      function assert_private() { }
    PRE_COND
  end

  context 'install_shared_job_hardware is false' do
    let(:facts) do
      { cd4pe_multimodule_packaging: true }
    end

    let(:params) do
      {
        resolvable_hostname: 'test.com',
        root_email: 'test@test.com',
        root_password: sensitive('test'),
        install_shared_job_hardware: false,
      }
    end

    it do
      is_expected.to contain_cd4pe_root_config('test.com:8080')
        .with_root_email('test@test.com')
        .with_root_password('test')
    end

    it { is_expected.not_to contain_class('pipelines::agent') }
  end
end
