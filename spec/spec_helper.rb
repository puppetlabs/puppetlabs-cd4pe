RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'shared/contexts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

default_facts = {
  architecture: 'x86_64',
  osfamily: 'RedHat',
  platform_tag: 'el-7-x86_64',
  operatingsystem: 'CentOS',
  lsbmajdistrelease: '7',
  operatingsystemrelease: '7.1',
  operatingsystemmajrelease: '7',
  is_pe: 'true',
  pe_concat_basedir: '/tmp/file',
  platform_symlink_writable: true,
  puppetversion: '4.5.1',
  aio_agent_version: '1.5.1',
  memorysize: '1.00 GB',
  processorcount: 1,
  id: 'root',
  gid: 'root',
  path: '/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/bin',
  mountpoints: { '/' => {} },
  puppet_files_dir_present: 'false',
  os: {
    'family' => 'RedHat',
    'name'                   => 'CentOS',
    'release'                => {
      'major' => '6',
    },
  },
  pe_build: '2018.1.0',
  memory: { 'system' => { 'total_bytes' => 4_294_967_296 } },
  processors: { 'count' => 1 },
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f)))
  rescue => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

module Helpers
  def pre_condition
    <<-PRE_COND
class {'puppet_enterprise':
  certificate_authority_host   => 'ca.rspec',
  puppet_master_host           => 'master.rspec',
  console_host                 => 'console.rspec',
  puppetdb_host                => 'puppetdb.rspec',
  database_host                => 'database.rspec',
  pcp_broker_host              => 'pcp_broker.rspec',
}
PRE_COND
  end
end

module RSpec::Puppet
  # Rspec-puppet has no support sensitive params...taken from open PR here:
  # https://github.com/rodjek/rspec-puppet/pull/464/files
  # A wrapper representing Sensitive data type, eg. in class params.
  class Sensitive
    # Create a new Sensitive object
    # @param [Object] value to wrap
    def initialize(value)
      @value = value
    end

    # @return the wrapped value
    def unwrap
      @value
    end

    # @return true
    def sensitive?
      true
    end

    # @return inspect of the wrapped value, inside Sensitive()
    def inspect
      "Sensitive(#{@value.inspect})"
    end

    # Check for equality with another value.
    # If compared to Puppet Sensitive type, it compares the wrapped values.

    # @param other [#unwrap, Object] value to compare to
    def ==(other)
      if other.respond_to? :unwrap
        unwrap == other.unwrap
      else
        super
      end
    end
  end
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.include Helpers, RSpec::Puppet::Sensitive
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
  end
end

def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last_module, next_module|
    last_module.const_set(next_module, Module.new) unless last_module.const_defined?(next_module, false)
    last_module.const_get(next_module, false)
  end
end

# Helper to return value wrapped in Sensitive type.
#
# @param [Object] value to wrap
# @return [RSpec::Puppet::Sensitive] a new Sensitive wrapper with the new value
def sensitive(value)
  RSpec::Puppet::Sensitive.new(value)
end

# 'spec_overrides' from sync.yml will appear below this line
