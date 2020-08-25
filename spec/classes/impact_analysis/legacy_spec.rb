require 'spec_helper'

RSpec.describe 'cd4pe::impact_analysis::legacy' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_enterprise':
        puppet_master_host           => 'master.rspec',
      }
      class {'puppet_enterprise::profile::master':}
    PRE_COND
  end

  let(:params) do
    {
      'allowed_certnames' => ['test'],
    }
  end

  context '2018.1.0' do
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2018.1.0'
      end
    end

    context 'valid params' do
      it { is_expected.to contain_puppet_authorization__rule('CDPE API access') }
      it {
        is_expected.to contain_file('/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar')
          .with_source('puppet:///modules/cd4pe/cdpe-api.jar')
      }

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
      let(:params) {}

      it { is_expected.not_to compile }
    end
  end

  context '2019.1.0' do
    let(:facts) do
      {
        pe_build: '2019.1.0',
      }
    end

    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2019.1.0'
      end
    end
    it {
      is_expected.to contain_file('/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar')
        .with_source('puppet:///modules/cd4pe/cdpe-api-aot.jar')
    }
  end
end
