require 'spec_helper'
require 'puppet/type/cd4pe_root_config'

RSpec.describe 'the cd4pe_root_config type' do
  it 'loads' do
    expect(Puppet::Type.type(:cd4pe_root_config)).not_to be_nil
  end
end
