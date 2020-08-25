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
          'allowed_certnames' => ['test'],
        }
      end

      it { is_expected.to contain_class('cd4pe::impact_analysis::legacy').with_ensure('present') }

      context 'ensure => absent' do
        let(:params) do
          {
            'allowed_certnames' => ['test'],
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
      it { is_expected.not_to contain_hocon_setting('enable lookup tracing') }
    end
  end

  describe '2019.2.0' do
    let(:facts) do
      {
        pe_build: '2019.2.0',
      }
    end
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2019.2.0'
      end
    end

    context 'enable hiera tracing' do
      it { is_expected.to contain_hocon_setting('enable lookup tracing') }
    end
  end
end
