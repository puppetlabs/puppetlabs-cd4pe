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
      'whitelisted_certnames' => ['test']
    }
  end

  context '2018.1.0' do
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        '2018.1.0'
      end
    end

    context 'valid params' do
      it { should contain_pe_puppet_authorization__rule('puppetlabs environment')
        .with_allow(['master.rspec', 'test'])}
      it { should contain_puppet_authorization__rule('CDPE API access') }
      it { should contain_file('/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar')
        .with_source('puppet:///modules/cd4pe/cdpe-api.jar') }

      context 'ensure => absent' do
        let(:params) do
          {
            'whitelisted_certnames' => ['test'],
            'ensure' => 'absent'
          }
        end
        it { should contain_class('cd4pe::impact_analysis::legacy').with_ensure('absent') }
      end
    end

    context 'invalid params' do
      let(:params) {}
      it { is_expected.to_not compile }
    end
  end

  context '2019.1.0' do
    let (:facts) do
      {
        pe_build: '2019.1.0'
      }
    end

    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        '2019.1.0'
      end
    end
    it { should contain_file('/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar')
        .with_source('puppet:///modules/cd4pe/cdpe-api-aot.jar') }

  end
end
