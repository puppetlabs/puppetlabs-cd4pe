require 'spec_helper'

RSpec.describe 'cd4pe::impact_analysis' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_enterprise':
        puppet_master_host           => 'master.rspec',
      }
      class {'puppet_enterprise::profile::master':}
    PRE_COND
  end

  context '2018.1.0' do
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2018.1.0'
      end
    end

    context 'valid params' do
      let(:params) do
        {
          'whitelisted_certnames' => ['test'],
        }
      end

      it { is_expected.to contain_class('cd4pe::impact_analysis::legacy').with_ensure('present') }
      it {
        is_expected.to contain_pe_puppet_authorization__rule('puppetlabs environment')
          .with_allow(['master.rspec', 'test'])
      }

      context 'ensure => absent' do
        let(:params) do
          {
            'whitelisted_certnames' => ['test'],
            'ensure' => 'absent',
          }
        end

        it { is_expected.to contain_class('cd4pe::impact_analysis::legacy').with_ensure('absent') }
      end
    end

    context 'invalid params' do
      it { is_expected.not_to compile }
    end
  end

  context '2019.1.0' do
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2019.1.0'
      end
    end

    context 'using the new code' do
      it { is_expected.to contain_class('cd4pe::impact_analysis::legacy').with_ensure('absent') }
      it {
        is_expected.to contain_pe_puppet_authorization__rule('puppetlabs environment')
          .with_allow(['master.rspec', { 'rbac' => { 'permission' => 'puppetserver:compile_catalog:*' } }])
      }
    end
  end
end
