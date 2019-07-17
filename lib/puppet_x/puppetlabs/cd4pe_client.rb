require 'puppet_x'
require 'net/http'
require 'uri'
require 'json'

module PuppetX::Puppetlabs
  # Provides a class for interacting with CD4PE's API
  class CD4PEClient < Object
    attr_reader :config

    LOGIN_ENDPOINT = '/login'.freeze
    ROOT_AJAX_ENDPOINT = '/root/ajax'.freeze
    ROOT_ENDPOINT_SETTINGS = '/root/endpoint-settings'.freeze
    ROOT_STORAGE_SETTINGS = '/root/storage-settings'.freeze
    SIGNUP_ENDPOINT = '/signup'.freeze

    def initialize(hostname, email = nil, password = nil)
      uri = URI.parse(hostname)

      @config = {
        server: uri.host,
        port: uri.port || '8080',
        scheme: uri.scheme || 'http',
        email: email,
        password: password,
      }
      # Only set the cookie if creds are provided, otherwise, make unauthenticated requests
      if @config[:email] && @config[:password]
        set_cookie
      end
    end

    def set_cookie
      content = {
        op: 'PfiLogin',
        content: {
          email: @config[:email],
          passwd: @config[:password],
        },
      }

      response = make_request(:post, LOGIN_ENDPOINT, content.to_json)
      if response.code == '200'
        @cookie = response.response['set-cookie'].split(';')[0]
        content = JSON.parse(response.body, symbolize_names: true)
        @owner_ajax_endpoint = "/#{content[:username]}/ajax"
      elsif response.code == '401'
        begin
          resp = JSON.parse(response.body, symbolize_names: true)
          if resp[:error][:code] == 'LoginFailed'
            # Root account may not exist, try creating it
            response = create_root_account
            if response.code == '200'
              @cookie = response.response['set-cookie'].split(';')[0]
            else
              raise Puppet::Error, "Invalid login credentials to CD4PE host: #{@config[:server]}"
            end
          else
            raise Puppet::Error, "Invalid login credentials to CD4PE host: #{@config[:server]}"
          end
        rescue
          raise Puppet::Error, "Invalid login credentials to CD4PE host: #{@config[:server]}"
        end
      else
        raise Puppet::Error, "Invalid login credentials to CD4PE host: #{@config[:server]}"
      end
    end

    def root_config
      endpoint = "#{ROOT_AJAX_ENDPOINT}?op=GetRootConfiguration"
      make_request(:get, endpoint)
    end

    attr_reader :cookie

    def create_root_account
      payload = {
        op: 'CreateRootAccount',
        content: {
          email: @config[:email],
          passwd: @config[:password],
        },
      }
      make_request(:post, '/root-account', payload.to_json)
    end

    def save_license(license)
      payload = {
        op: 'RootSavePfiLicense',
        content: license,
      }
      make_request(:post, ROOT_AJAX_ENDPOINT, payload.to_json)
    end

    def save_endpoint_settings(webui, backend, agent)
      payload = {
        op: 'SaveEndpointSettings',
        content: {
          setting: {
            webUIEndpoint: webui,
            backendServiceEndpoint: backend,
            agentServiceEndpoint: agent,
          },
        },
      }
      make_request(:post, ROOT_ENDPOINT_SETTINGS, payload.to_json)
    end

    def save_storage_settings(provider, endpoint, bucket, prefix, access_key = nil, secret_key = '')
      # CDPE-1195 - CD4PE attempts to encrypt the secret even if using DISK storage. Send an
      # empty string for now if the caller passed in nil
      secret_key = '' if secret_key.nil?
      payload = {
        op: 'SaveStorageSettings',
        content: {
          setting: {
            osType: provider,
            osEndpoint: endpoint,
            osDiskRoot: '/disk',
            osBucket: bucket,
            osPrefix: prefix,
            osCredKey: access_key,
            osCredSecret: secret_key,
          },
        },
      }
      make_request(:post, ROOT_STORAGE_SETTINGS, payload.to_json)
    end

    def add_oauth_integration(provider, client_id, client_secret)
      payload = {
        op: 'AddOauthIntegration',
        content: {
          provider: provider,
          publicKey: client_id,
          privateKey: client_secret,
        },
      }
      make_request(:post, ROOT_AJAX_ENDPOINT, payload.to_json)
    end

    def discover_pe_credentials(creds_name, pe_username, pe_password, pe_token, pe_console_host)
      payload = {
        op: 'DiscoverPuppetEnterpriseCredentials',
        content: {
          consoleHost: pe_console_host,
          name: creds_name,
          username: pe_username,
          password: pe_password,
          token: pe_token,
          puppetServerCertificate: '',
          puppetServerEndpoint: '',
          puppetServerPrivateKey: '',
        },
      }
      make_request(:post, @owner_ajax_endpoint, payload.to_json)
    end

    def add_control_repo(repo_provider, repo_org, source_repo_name, control_repo_name)
      repos_res = search_source_repos(repo_provider, repo_org, source_repo_name)
      if repos_res.code != '200'
        raise Puppet::Error, "Error while searching for repository: #{repos_res.body}"
      end
      source_repos = JSON.parse(repos_res.body, symbolize_names: true)
      raise Puppet::Error, "Aborting.. Could not find repository for name: #{repo_name}" if source_repos.empty?
      raise Puppet::Error, "Aborting.. Found multiple repositories for repository name: #{repo_name}" if source_repos.length > 1
      # There should only be one repo from the search
      source_repo = source_repos[0]
      payload = {
        op: 'CreateControlRepo',
        content: {
          name: control_repo_name,
          srcRepoDisplayName: source_repo[:repoDisplayName],
          srcRepoDisplayOwner: source_repo[:ownerDisplayName],
          srcRepoId: source_repo[:repoId],
          srcRepoName: source_repo[:repoName],
          srcRepoOwner: source_repo[:owner],
          # The search API returns the value of the provider as an lowercase string. It needs to be uppercase when creating a control repo.
          srcRepoProvider: source_repo[:provider].upcase,
        },
      }
      make_request(:post, @owner_ajax_endpoint, payload.to_json)
    end

    def search_source_repos(repo_provider, repo_org, repo_name)
      params = {
        op: 'SearchSourceRepos',
        provider: repo_provider,
        org: repo_org,
        search: repo_name,
      }
      api_uri = URI(@owner_ajax_endpoint)
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def create_pipeline(pipeline_name, control_repo_name, control_repo_branch)
      # Default sources
      sources = [
        {
          autoBuildTriggers: ['Commit'],
          branch: control_repo_branch,
          containerName: control_repo_branch,
          trigger: 'SOURCE_REPOSITORY',
        },
      ]
      payload = {
        op: 'CreatePipeline',
        content: {
          controlRepoName: control_repo_name,
          pipelineName: pipeline_name,
          sources: sources,
        },
      }
      make_request(:post, @owner_ajax_endpoint, payload.to_json)
    end

    def post_provider_webhook(source_repo_name, source_repo_owner, source_repo_provider)
      payload = {
        op: 'PostProviderWebhook',
        content: {
          srcRepoName: source_repo_name,
          srcRepoOwner: source_repo_owner,
          srcRepoProvider: source_repo_provider,
        },
      }
      make_request(:post, @owner_ajax_endpoint, payload.to_json)
    end

    def save_ssl_settings(ssl_authority_certificate, ssl_server_certificate, ssl_server_private_key, ssl_enabled)
      payload = {
        op: 'SaveSslSettings',
        content: {
          setting: {
            authorityCertificate: ssl_authority_certificate,
            serverCertificate: ssl_server_certificate,
            serverPrivateKey: ssl_server_private_key,
            sslEnabled: ssl_enabled,
          },
        },
      }
      make_request(:post, ROOT_AJAX_ENDPOINT, payload.to_json)
    end

    def create_user(email, username, password, first_name, last_name, company_name)
      payload = {
        op: 'PfiSignup',
        content: {
          email: email,
          passwd: password,
          username: username,
          firstName: first_name,
          lastName: last_name,
          companyName: company_name,
        },
      }
      make_request(:post, SIGNUP_ENDPOINT, payload.to_json)
    end

    def create_agent_credentials()
      endpoint = "#{ROOT_AJAX_ENDPOINT}?op=CreateAgentCredentials"
      make_request(:get, endpoint)
    end

    def list_agent_credentials()
      endpoint = "#{ROOT_AJAX_ENDPOINT}?op=ListAgentCredentials"
      make_request(:get, endpoint)
    end

    def list_servers()
      endpoint = "#{ROOT_AJAX_ENDPOINT}?op=ListServers"
      make_request(:get, endpoint)
    end

    private

    def make_request(type, api_url, payload = '')
      connection = Net::HTTP.new(@config[:server], @config[:port])
      headers = {
        'Content-Type' => 'application/json',
        'Cookie' => @cookie,
      }

      max_attempts = 5
      attempts = 0

      while attempts < max_attempts
        attempts += 1
        begin
          Puppet.debug("cd4pe_client: requesting #{type} #{api_url}")
          case type
          when :delete
            response = connection.delete(api_url, headers)
          when :get
            response = connection.get(api_url, headers)
          when :post
            response = connection.post(api_url, payload, headers)
          when :put
            response = connection.put(api_url, payload, headers)
          else
            raise Puppet::Error, "cd4pe_client#make_request called with invalid request type #{type}"
          end
        rescue SocketError => e
          raise Puppet::Error, "Could not connect to the CD4PE service at #{service_url}: #{e.inspect}", e.backtrace
        end

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          return response
          # PE-15108 Retry on 500 (Internal Server Error) and 400 (Bad request) errors
        when Net::HTTPInternalServerError, Net::HTTPBadRequest
          if attempts < max_attempts
            Puppet.debug("Received #{response} error from #{service_url}, attempting to retry. (Attempt #{attempts} of #{max_attempts})")
            Kernel.sleep(10)
          else
            raise Puppet::Error, "Received #{attempts} server error responses from the CD4PE service at #{service_url}: #{response.code} #{response.body}"
          end
        else
          return response
        end
      end
    end

    # Helper method for returning a user friendly url for the CD4PE instance being used.
    def service_url
      "#{@config[:scheme]}://#{@config[:server]}:#{@config[:port]}"
    end
  end
end
