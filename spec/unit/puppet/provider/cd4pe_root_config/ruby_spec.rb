require 'spec_helper'

ensure_module_defined('Puppet::Provider::Cd4peRootConfig')
require 'puppet/provider/cd4pe_root_config/ruby'

describe Puppet::Type.type(:cd4pe_root_config).provider(:ruby) do
  # Helper method to generate a pe_node_group resource based on default params
  def generate_resource(parameters = {})
    parameters[:name]                ||= 'stub_name'
    parameters[:resolvable_hostname] ||= 'master.rspec'
    parameters[:root_email]          ||= 'admin@puppet.com'
    parameters[:root_password]       ||= 'puppetlabs'

    Puppet::Type.type(:cd4pe_root_config).new(parameters)
  end

  let(:stub_server) { 'stubserver' }
  let(:stub_port) { 8080 }
  let(:api_url) { "https://#{stub_server}:#{stub_port}/classifier-api/v1/groups" }

  let(:resource) { generate_resource }
  let(:provider) { described_class.new(resource) }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  describe '.instances' do
    it 'returns each node group' do
      res = provider.class.instances
      expect(res.count).to be(1)
      expect(res[0]).to be_a(Puppet::Provider)
    end
  end
end
