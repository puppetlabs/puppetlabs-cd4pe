require 'puppet/parameter/boolean'
require 'puppet/property/boolean'

# Based off prosvcs-node_manager. The major difference
# is it does not rely on a gem for interacting with the classifier.
# https://github.com/puppetlabs/prosvcs-node_manager
Puppet::Type.newtype(:cd4pe_root_config) do
  @doc = %q{
  }
  ensurable

  newparam(:resolvable_hostname, :namevar => true) do
    desc ''
    validate do |value|
      fail '' if value == ''
      fail 'cd4pe_hostname should be a resolvable hostname' unless value.is_a?(String)
    end
  end

  newproperty(:root_email) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end

  end

  newproperty(:root_password) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
  end

  newproperty(:web_ui_endpoint) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:backend_service_endpoint) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:agent_service_endpoint) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end


  newproperty(:storage_provider) do
    desc ''
    defaultto :DISK
    newvalues(:DISK, :S3, :ARTIFACTORY)
  end

  newproperty(:storage_endpoint) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:storage_disk_root) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
  end

  newproperty(:storage_bucket) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
  end

  newproperty(:storage_prefix) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
  end

  newproperty(:s3_access_key) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
  end

  newproperty(:s3_secret_key) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      true
    end
  end

  newproperty(:artifactory_access_token) do
    desc ''
    validate do |value|
      fail '' unless value.is_a?(String)
    end
    def insync?(is)
      true
    end
  end
end

def compare_uris(is, should)
  begin
    URI.parse(is) == URI.parse(should)
  rescue
    false
  end
end
