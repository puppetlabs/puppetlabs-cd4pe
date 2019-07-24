require 'spec_helper'
require_relative '../../lib/puppet/functions/cd4pe/has_job_hardware'
require 'webmock/rspec'

describe 'cd4pe::has_job_hardware' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'requires 3 parameters' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  context 'happy path' do
    include_context 'cd4pe login'

    let(:res_list_servers_empty) do
      {
        rows: [],
      }
    end
    let(:res_list_servers) do
      {
        rows: [
          {
            some_key: 'there be servers here',
          },
        ],
      }
    end

    it 'returns false if servers response is empty' do
      stub_request(:get, hw_config_url)
        .with(query: 'op=ListServers', headers: { 'Cookie' => req_cookie })
        .to_return(body: JSON.generate(res_list_servers_empty))
        .times(1)

      is_expected.to run.with_params(test_host, 'test@test.com', Puppet::Pops::Types::PSensitiveType::Sensitive.new('test')).and_return(false)
    end

    it 'returns true if servers response is not empty' do
      stub_request(:get, hw_config_url)
        .with(query: 'op=ListServers', headers: { 'Cookie' => req_cookie })
        .to_return(body: JSON.generate(res_list_servers))
        .times(1)

      is_expected.to run.with_params(test_host, 'test@test.com', Puppet::Pops::Types::PSensitiveType::Sensitive.new('test')).and_return(true)
    end
  end
end
