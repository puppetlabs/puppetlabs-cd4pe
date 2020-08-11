require 'spec_helper'

RSpec.describe('cd4pe::deprovision') do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_enterprise':
        puppet_master_host           => 'master.rspec',
      }
      class {'puppet_enterprise::profile::master':}
      function assert_private() { }
    PRE_COND
  end

  context 'cleanup' do
    context 'managing database' do
      context 'mysql' do
        let(:facts) do
            {
            os: { 
                'family' => 'RedHat',
                'name' => 'CentOS',
                release: { 
                    'major' => '7'
                    } 
                }
            }
        end
        let(:params) do
          {
            db_provider: 'mysql',
          }
        end

        it { is_expected.to_not contain_class('cd4pe::db::mysql') }
      end

      context 'postgres' do
        let(:facts) do
          { cd4pe_multimodule_packaging: true, 
            os: { 
                'family' => 'RedHat',
                'name' => 'CentOS',
                release: { 
                    'major' => '7'
                    } 
                }
          }
        end
        let(:params) do
          {
            db_provider: 'postgres',
          }
        end

        it { is_expected.to_not contain_class('cd4pe::db::postgres') }
      end
    end
  end
end