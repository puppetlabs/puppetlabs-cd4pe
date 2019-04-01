require 'puppet/parameter/boolean'
require 'puppet/property/boolean'

Puppet::Type.newtype(:cd4pe_root_config) do
  @doc = %q{
  Full documentation available at https://puppet.com/docs/continuous-delivery/latest/install_module.html#task-7157
  }
  ensurable

  newparam(:resolvable_hostname, :namevar => true) do
    desc 'The resolvable address that the CD4PE service will be available at'
    validate do |value|
      fail '' if value == ''
      fail 'cd4pe_hostname should be a resolvable hostname' unless value.is_a?(String)
    end
  end

  newproperty(:root_email) do
    desc 'The email address to associate with the root account.'
    validate do |value|
      fail 'root_email must be a String' unless value.is_a?(String)
    end

  end

  newproperty(:root_password) do
    desc 'The password to associate with the root account.'
    validate do |value|
      fail 'root_password must be a String' unless value.is_a?(String)
    end
  end

  newproperty(:web_ui_endpoint) do
    desc 'The endpoint where the web UI can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      fail 'web_ui_endpoint must be a String' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:backend_service_endpoint) do
    desc 'The endpoint where the back end service can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      fail 'backend_service_endpoint must be a String' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:agent_service_endpoint) do
    desc 'The endpoint where the agent service can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      fail 'agent_service_endpoint must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end


  newproperty(:storage_provider) do
    desc 'Which object store provider to use. Must be one of: DISK, ARTIFACTORY or S3.'
    defaultto :DISK
    newvalues(:DISK, :S3, :ARTIFACTORY)
  end

  newproperty(:storage_endpoint) do
    desc 'The URL of the storage provider.'
    validate do |value|
      fail 'storage_endpoint must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is,should)
    end
  end

  newproperty(:storage_bucket) do
    desc 'The name of the bucket used for object storage.'
    validate do |value|
      fail 'storage_bucket must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:storage_prefix) do
    desc 'For Amazon S3: the subdirectory of the bucket to use. For Artifactory: the top level of the Artifactory instance.'
    validate do |value|
      fail 'storage_prefix must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:s3_access_key) do
    desc 'The AWS access key that has access to the bucket.'
    validate do |value|
      fail 's3_access_key must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:s3_secret_key) do
    desc 'The AWS secret key that has access to the bucket.'
    validate do |value|
      fail 's3_secret_key must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      true
    end
  end

  newproperty(:artifactory_access_token) do
    desc 'API token for your Artifactory instance.'
    validate do |value|
      fail 'artifactory_access_token must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      true
    end
  end

  newproperty(:ssl_enabled, :boolean => false, :parent => Puppet::Property::Boolean) do
    desc 'Boolean to enable or disable SSL'
  end

  newproperty(:server_certificate) do
    desc 'Server Certificate for your SSL configuration.'
    validate do |value|
      fail 'server_certificate must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:authority_certificate) do
    desc 'Authority Certificate for your SSL configuration.'
    validate do |value|
      fail 'authority_certificate must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:server_private_key) do
    desc 'Server Private Key for your SSL configuration.'
    validate do |value|
      fail 'server_private_key must be a String.' unless value.is_a?(String)
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
