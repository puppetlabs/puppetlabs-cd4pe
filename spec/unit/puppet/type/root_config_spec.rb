require 'spec_helper'
require 'puppet/type/root_config'

RSpec.describe 'the root_config type' do
  it 'loads' do
    expect(Puppet::Type.type(:root_config)).not_to be_nil
  end
end
