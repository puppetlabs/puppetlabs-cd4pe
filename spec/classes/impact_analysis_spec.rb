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

  context '2021.1.0' do
    before :each do
      Puppet::Parser::Functions.newfunction(:pe_build_version, type: :rvalue) do |_args|
        '2021.1.0'
      end
    end

    it { is_expected.to contain_class('cd4pe::impact_analysis::legacy').with_ensure('absent') }
    it { is_expected.to contain_hocon_setting('enable lookup tracing') }
  end

end
