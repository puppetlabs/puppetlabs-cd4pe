require 'puppet_x/puppetlabs/cd4pe_client'

Puppet::Type.type(:cd4pe_root_config).provide(:ruby) do
  mk_resource_methods

  def self.instances
    providers = []
    @clients.each do |hostname, v|
      client = v[:client]
      existing_config = client.get_root_config

      if existing_config.code == '200'
        existing_config = JSON.parse(existing_config.body, symbolize_names: true)
        resource = v[:resource]

        resource_hash = {
          ensure: :present,
          resolvable_hostname: resource[:resolvable_hostname],
          root_email: resource[:root_email],
          root_password: resource[:root_password],
          web_ui_endpoint: existing_config[:webUIEndpoint],
          backend_service_endpoint: existing_config[:backendServiceEndpoint],
          agent_service_endpoint: existing_config[:agentServiceEndpoint],
          storage_provider: existing_config[:storageMethod],
          storage_endpoint: existing_config[:storageEndpoint] || '',
          storage_bucket: existing_config[:storageBucket],
          storage_prefix: existing_config[:storagePathPrefix] || '',
          s3_access_key: existing_config[:storageCredentialsKey] || '',
          ssl_enabled: existing_config[:sslEnabled] || false,
          ssl_server_certificate: existing_config[:serverCertificate] || '',
          ssl_authority_certificate: existing_config[:authorityCertificate] || '',
          ssl_server_private_key: existing_config[:serverPrivateKey] || '',
        }
      end
      providers << new(resource_hash)
    end
    providers
  end

  def self.prefetch(resources)
    @clients = {}
    resources.values.each do |r|
      hostname = r[:resolvable_hostname]
      username = r[:root_email]
      password = r[:root_password]
      @clients[r[:resolvable_hostname]] = {
        client: init_api_client(hostname, username, password),
        resource: r
      }
    end

    existing_configs = instances
    resources.keys.each do |config|
      if provider = existing_configs.find { |c| c.resolvable_hostname.downcase == config.downcase }
        resources[config].provider = provider
      end
    end
  end

  def exists?
    Puppet.info("Checking if CD4PE is configured at #{name}")
    @property_hash[:ensure] == :present
  end

  def create
    @noflush = true
    hostname = @resource[:resolvable_hostname]
    username = @resource[:root_email]
    password = @resource[:root_password]
    self.class.init_api_client(hostname, username, password)
    resp = save_endpoint_settings(@resource)
    endpoint_success = resp.code == '200'
    resp = save_storage_settings(resource)
    storage_success = resp.code == '200'
    resp = save_ssl_settings(@resource)
    ssl_success = resp.code == '200'

    if endpoint_success && storage_success && ssl_success
      @resource.original_parameters.each_key do |k|
        if k == :ensure
          @property_hash[:ensure] = :present
        else
          @property_hash[k]       = @resource[k]
        end
      end
    end
    endpoint_success && storage_success && ssl_success
  end

  def destroy
    raise Puppet::Error("cd4pe_root_config does not currently handle ensure => :absent")
  end

  def flush
    return if @noflush
    hostname = @resource[:resolvable_hostname]
    username = @resource[:root_email]
    password = @resource[:root_password]
    self.class.init_api_client(hostname, username, password)
    resp = save_endpoint_settings(@resource)
    endpoint_success = resp.code == '200'
    resp = save_storage_settings(resource)
    storage_success = resp.code == '200'
    resp = save_ssl_settings(@resource)
    ssl_success = resp.code == '200'

    if endpoint_success && storage_success && ssl_success
      @resource.original_parameters.each_key do |k|
        if k == :ensure
          @property_hash[:ensure] = :present
        else
          @property_hash[k]       = @resource[k]
        end
      end
    end
    endpoint_success && storage_success && ssl_success
  end

  private
  def save_storage_settings(resource)
    provider = resource[:storage_provider]
    endpoint = resource[:storage_endpoint]
    bucket = resource[:storage_bucket]
    prefix = resource[:storage_prefix]
    access_key = resource[:s3_access_key]
    secret_key = resource[:s3_secret_key]
    secret_key ||= resource[:artifactory_access_token]

    self.class.api_client.save_storage_settings(
      provider, endpoint, bucket, prefix, access_key, secret_key)
  end

  def save_endpoint_settings(resource)
    web_ui_endpoint = resource[:web_ui_endpoint]
    backend_service_endpoint = resource[:backend_service_endpoint]
    agent_service_endpoint = resource[:agent_service_endpoint]
    self.class.api_client.save_endpoint_settings(
      web_ui_endpoint, backend_service_endpoint, agent_service_endpoint)
  end

  def save_ssl_settings(resource)
    ssl_enabled = resource[:ssl_enabled]
    ssl_server_certificate = resource[:ssl_server_certificate]
    ssl_authority_certificate = resource[:ssl_authority_certificate]
    ssl_server_private_key = resource[:ssl_server_private_key]
    self.class.api_client.save_ssl_settings(
      ssl_authority_certificate, ssl_server_certificate, ssl_server_private_key, ssl_enabled)
  end

  def self.api_client
    @api_client
  end

  def self.init_api_client(hostname, username, password)
    @api_client ||= PuppetX::Puppetlabs::CD4PEClient.new(hostname, username, password)
  end
end
