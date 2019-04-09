RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_local.rb'))

include RspecPuppetFacts

default_facts = {
    :osfamily                  => 'RedHat',
    :platform_tag              => 'el-6-x86_64',
    :operatingsystem           => 'CentOS',
    :lsbmajdistrelease         => '6',
    :operatingsystemrelease    => '6.1',
    :is_pe                     => 'true',
    :pe_concat_basedir         => '/tmp/file',
    :platform_symlink_writable => true,
    :puppetversion             => '4.5.1',
    :aio_agent_version         => '1.5.1',
    :memorysize                => '1.00 GB',
    :processorcount            => 1,
    :id                        => 'root',
    :gid                       => 'root',
    :path                      => '/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/bin',
    :mountpoints               => { '/' => {}},
    :puppet_files_dir_present  => 'false',
    :os                        => {
      'family'                 => 'RedHat',
      'name'                   => 'CentOS',
      'release'                => {
        'major'                => '6',
      },
    },
    :pe_build                  => '2018.1.0',
    :memory                    => { 'system' => { 'total_bytes' => 4294967296 } },
    :processors                => { 'count' => 1 },
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

RSpec.configure do |c|
  c.default_facts = default_facts
  c.include Helpers
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

# 'spec_overrides' from sync.yml will appear below this line
