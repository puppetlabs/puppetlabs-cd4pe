require 'puppet/parameter/boolean'
require 'puppet/property/boolean'

Puppet::Type.newtype(:cd4pe_root_config) do
  @doc = '
  Full documentation available at https://puppet.com/docs/continuous-delivery/latest/install_module.html#task-7157
  '
  ensurable

  newparam(:resolvable_hostname, namevar: true) do
    desc 'The resolvable address that the CD4PE service will be available at'
    validate do |value|
      raise '' if value == ''
      raise 'cd4pe_hostname should be a resolvable hostname' unless value.is_a?(String)
    end
  end

  newproperty(:root_email) do
    desc 'The email address to associate with the root account.'
    validate do |value|
      raise 'root_email must be a String' unless value.is_a?(String)
    end
  end

  newproperty(:root_password) do
    desc 'The password to associate with the root account.'
    validate do |value|
      raise 'root_password must be a String' unless value.is_a?(String)
    end
  end

  newproperty(:web_ui_endpoint) do
    desc 'The endpoint where the web UI can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      raise 'web_ui_endpoint must be a String' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is, should)
    end
  end

  newproperty(:backend_service_endpoint) do
    desc 'The endpoint where the back end service can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      raise 'backend_service_endpoint must be a String' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is, should)
    end
  end

  newproperty(:agent_service_endpoint) do
    desc 'The endpoint where the agent service can be reached, in the form http://<resolvable_hostname>:<port>.'
    validate do |value|
      raise 'agent_service_endpoint must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is, should)
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
      raise 'storage_endpoint must be a String.' unless value.is_a?(String)
    end
    def insync?(is)
      compare_uris(is, should)
    end
  end

  newproperty(:storage_bucket) do
    desc 'The name of the bucket used for object storage.'
    validate do |value|
      raise 'storage_bucket must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:storage_prefix) do
    desc 'For Amazon S3: the subdirectory of the bucket to use. For Artifactory: the top level of the Artifactory instance.'
    validate do |value|
      raise 'storage_prefix must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:s3_access_key) do
    desc 'The AWS access key that has access to the bucket.'
    validate do |value|
      raise 's3_access_key must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:s3_secret_key) do
    desc 'The AWS secret key that has access to the bucket.'
    validate do |value|
      raise 's3_secret_key must be a String.' unless value.is_a?(String)
    end
    def insync?(_is)
      true
    end
  end

  newproperty(:artifactory_access_token) do
    desc 'API token for your Artifactory instance.'
    validate do |value|
      raise 'artifactory_access_token must be a String.' unless value.is_a?(String)
    end
    def insync?(_is)
      true
    end
  end

  newproperty(:ssl_enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Boolean to enable or disable SSL'

    # We need to munge the values from boolean values to symbols due to a long standing
    # bug in puppet where it can't enforce falsey values on custom types.
    # See https://tickets.puppetlabs.com/browse/PUP-2368
    munge do |value|
      if value
        :true
      else
        :false
      end
    end
  end

  newproperty(:ssl_server_certificate) do
    desc 'Server Certificate for your SSL configuration.'
    validate do |value|
      raise 'ssl_server_certificate must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:ssl_authority_certificate) do
    desc 'Authority Certificate for your SSL configuration.'
    validate do |value|
      raise 'ssl_authority_certificate must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:ssl_server_private_key) do
    desc 'Server Private Key for your SSL configuration.'
    validate do |value|
      raise 'ssl_server_private_key must be a String.' unless value.is_a?(String)
    end
    def insync?(_is)
      true
    end
  end

  newproperty(:ssl_endpoint) do
    desc 'SSL Web UI Endpoint for your SSL configuration.'
    validate do |value|
      raise 'ssl_endpoint must be a String.' unless value.is_a?(String)
    end
  end

  newproperty(:ssl_port) do
    desc 'SSL Web UI Port for your SSL configuration.'
    validate do |value|
      raise 'ssl_port must be an Integer.' unless value.is_a?(Integer)
    end
  end

  newproperty(:install_shared_job_hardware, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Boolean to enable installation of job hardware'

    # We need to munge the values from boolean values to symbols due to a long standing
    # bug in puppet where it can't enforce falsey values on custom types.
    # See https://tickets.puppetlabs.com/browse/PUP-2368
    munge do |value|
      if value
        :true
      else
        :false
      end
    end
  end
end

def compare_uris(is, should)
  URI.parse(is) == URI.parse(should)
rescue
  false
end
