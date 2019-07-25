require 'spec_helper'
require_relative '../../lib/puppet/functions/cd4pe/get_agent_credentials'
require 'webmock/rspec'

describe 'cd4pe::get_agent_credentials' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'requires 3 parameters' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  context 'happy path' do
    include_context 'cd4pe login'

    context 'credentials found' do
      context 'active found' do
        let(:res_list_agent_credentials) do
          [
            {
              'accessToken' => 'ODKFS0N11A9G01XT3Z3W8O1U7',
              'createTime' => '1563895877768',
              'description' => 'Agent Credential',
              'secretKey' => 'p5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
              'status' => 'Active',
            },
          ]
        end

        let(:expected_hash) do
          {
            'access_token' => 'ODKFS0N11A9G01XT3Z3W8O1U7',
            'secret_key' => 'p5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
          }
        end

        it 'returns a hash' do
          stub_request(:get, hw_config_url)
            .with(query: 'op=ListAgentCredentials', headers: { 'Cookie' => req_cookie })
            .to_return(body: JSON.generate(res_list_agent_credentials))
            .times(1)
          is_expected.to run.with_params(test_host, 'test@test.com', Puppet::Pops::Types::PSensitiveType::Sensitive.new('test')).and_return(expected_hash)
        end
      end
      context 'inactive found' do
        let(:res_list_agent_credentials) do
          [
            {
              'accessToken' => 'ODKFS0N11A9G01XT3Z3W8O1U7',
              'createTime' => '1563895877768',
              'description' => 'Agent Credential',
              'secretKey' => 'p5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
              'status' => 'Inactive',
            },
          ]
        end

        let(:res_create_agent_credentials) do
          {
            'accessToken' => '4DKFS0N11A9G01XT3Z3W8O1U7',
            'createTime' => '1563895877768',
            'description' => 'Agent Credential',
            'secretKey' => 't5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
            'status' => 'Active',
          }
        end

        let(:expected_hash) do
          {
            'access_token' => '4DKFS0N11A9G01XT3Z3W8O1U7',
            'secret_key' => 't5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
          }
        end

        it 'returns a hash' do
          stub_request(:get, hw_config_url)
            .with(query: 'op=ListAgentCredentials', headers: { 'Cookie' => req_cookie })
            .to_return(body: JSON.generate(res_list_agent_credentials))
            .times(1)
          stub_request(:get, hw_config_url)
            .with(query: 'op=CreateAgentCredentials', headers: { 'Cookie' => req_cookie })
            .to_return(body: JSON.generate(res_create_agent_credentials))
            .times(1)
          is_expected.to run.with_params(test_host, 'test@test.com', Puppet::Pops::Types::PSensitiveType::Sensitive.new('test')).and_return(expected_hash)
        end
      end
    end

    context 'no credentials found' do
      let(:res_list_agent_credentials) do
        []
      end

      let(:res_create_agent_credentials) do
        {
          'accessToken' => 'ODKFS0N11A9G01XT3Z3W8O1U7',
          'createTime' => '1563895877768',
          'description' => 'Agent Credential',
          'secretKey' => 'p5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
          'status' => 'Active',
        }
      end

      let(:expected_hash) do
        {
          'access_token' => 'ODKFS0N11A9G01XT3Z3W8O1U7',
          'secret_key' => 'p5y8pt7btj7vetiroee7b4j7r8j4q31crf91z',
        }
      end

      it 'calls create endpoint and returns hash' do
        stub_request(:get, hw_config_url)
          .with(query: 'op=ListAgentCredentials', headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(res_list_agent_credentials))
          .times(1)
        stub_request(:get, hw_config_url)
          .with(query: 'op=CreateAgentCredentials', headers: { 'Cookie' => req_cookie })
          .to_return(body: JSON.generate(res_create_agent_credentials))
          .times(1)
        is_expected.to run.with_params(test_host, 'test@test.com', Puppet::Pops::Types::PSensitiveType::Sensitive.new('test')).and_return(expected_hash)
      end
    end
  end
end
