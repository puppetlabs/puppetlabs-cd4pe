require 'spec_helper'

RSpec.describe 'cd4pe::db' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_enterprise':
        puppet_master_host           => 'master.rspec',
      }
      class {'puppet_enterprise::profile::master':}
      function assert_private() { }
    PRE_COND
  end

  context 'fresh install' do
    context 'managing database' do
      context 'mysql' do
        let(:params) do
          {
            data_root_dir: '/etc/puppetlabs/cd4pe',
            db_host: 'cd4pe.example',
            db_name: 'cd4pe',
            db_port: 3306,
            db_user: 'cd4pe',
            db_provider: 'mysql',
            db_pass: sensitive('passw0rd'),
          }
        end

        it { is_expected.to contain_class('cd4pe::db::mysql') }
      end

      context 'postgres' do
        let(:params) do
          {
            data_root_dir: '/etc/puppetlabs/cd4pe',
            db_host: 'cd4pe.example',
            db_name: 'cd4pe',
            db_port: 3306,
            db_user: 'cd4pe',
            db_provider: 'postgres',
            db_pass: sensitive('passw0rd'),
          }
        end

        it { is_expected.to contain_class('cd4pe::db::postgres') }
      end
    end
  end

  context 'upgrade' do
    context 'existing mysql' do
      let(:facts) do
        {
          docker: {
            network: {
              cd4pe: {
                Containers: {
                  foo: {
                    Name: 'cd4pe_mysql',
                  },
                },
              },
            },
          },
        }
      end

      let(:params) do
        {
          data_root_dir: '/etc/puppetlabs/cd4pe',
          db_host: 'cd4pe.example',
          db_name: 'cd4pe',
          db_port: 3306,
          db_user: 'cd4pe',
          db_pass: sensitive('passw0rd'),
        }
      end

      it { is_expected.to contain_class('cd4pe::db::mysql') }
    end
  end
end
