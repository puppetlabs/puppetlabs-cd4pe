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
    HW_CONFIG_ENDPOINT = '/root/hw-config'.freeze

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

    def get_ajax_endpoint(workspace)
      "/#{workspace}/ajax"
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
        JSON.parse(response.body, symbolize_names: true)
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

    def discover_pe_credentials(workspace, creds_name, pe_username, pe_password, pe_token, pe_console_host)
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
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def add_repo(workspace, repo_provider, repo_org, source_repo_name, repo_name, repo_type)
      repos_res = search_source_repos(workspace, repo_provider, repo_org, source_repo_name)
      if repos_res.code != '200'
        raise Puppet::Error, "Error while searching for repository: #{repos_res.body}"
      end
      source_repos = JSON.parse(repos_res.body, symbolize_names: true)
      if source_repos.empty?
        raise Puppet::Error, "Could not find repository for name: #{repo_name}"
      end
      if source_repos.length > 1
        raise Puppet::Error, "Found multiple repositories for repository name: #{repo_name}"
      end
      # There should only be one repo from the search
      source_repo = source_repos[0]
      case repo_type
      when 'control'
        repo_op = 'CreateControlRepo'
      when 'module'
        repo_op = 'CreateModule'
      else
        raise Puppet::Error "repo_type does not match one of: 'control', 'module'"
      end

      payload = {
        op: repo_op,
        content: {
          name: repo_name,
          srcRepoDisplayName: source_repo[:repoDisplayName],
          srcRepoDisplayOwner: source_repo[:ownerDisplayName],
          srcRepoId: source_repo[:repoId],
          srcRepoName: source_repo[:repoName],
          srcRepoOwner: source_repo[:owner],
          # The search API returns the value of the provider as an lowercase string. It needs to be uppercase when creating a control repo.
          srcRepoProvider: source_repo[:provider].upcase,
        },
      }
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def search_source_repos(workspace, repo_provider, repo_org, repo_name)
      params = {
        op: 'SearchSourceRepos',
        provider: repo_provider,
        org: repo_org,
        search: repo_name,
      }
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def list_job_templates(workspace)
      # This does not use pagination because the frontend doesn't so this is consistent.
      # TODO: Use pagination here or add search functionality (CDPE-2280)
      params = {
        op: 'ListVmJobTemplates',
      }
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def create_pipeline(workspace, pipeline_name, repo_name, repo_branch, pipeline_type)
      # Default sources
      sources = [
        {
          autoBuildTriggers: ['Commit'],
          branch: repo_branch,
          containerName: repo_branch,
          trigger: 'SOURCE_REPOSITORY',
        },
      ]
      payload = {
        op: 'CreatePipeline',
        content: {
          pipelineName: pipeline_name,
          sources: sources,
        },
      }

      if pipeline_type == 'control'
        payload[:content][:controlRepoName] = repo_name
      elsif pipeline_type == 'module'
        payload[:content][:moduleName] = repo_name
      end
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def upsert_pipeline_stages(workspace, repo_name, pipeline_type, pipeline_id, stages)
      payload = {
        op: 'UpsertPipelineStages',
        content: {
          pipelineId: pipeline_id,
          stages: stages,
        },
      }

      if pipeline_type == 'control'
        payload[:content][:controlRepoName] = repo_name
      elsif pipeline_type == 'module'
        payload[:content][:moduleName] = repo_name
      end
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def set_pipeline_auto_build_triggers(workspace, repo_name, pipeline_type, pipeline_id, branch, triggers)
      payload = {
        op: 'SetPipelineAutoBuildTriggers',
        content: {
          pipelineId: pipeline_id,
          rule: {
            autoBuildTriggers: triggers,
            branch: branch,
          },
        },
      }

      case pipeline_type
      when 'control'
        payload[:content][:controlRepoName] = repo_name
      when 'module'
        payload[:content][:moduleName] = repo_name
      else
        raise Puppet::Error "pipeline_type does not match one of: 'control', 'module'"
      end
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def set_is_build_pr_allowed(workspace, repo_name, repo_type, is_allowed)
      payload = {
        op: 'SetIsBuildPRAllowed',
        content: {
          isBuildPRAllowed: is_allowed,
        },
      }
      case repo_type
      when 'control'
        payload[:content][:controlRepoName] = repo_name
      when 'module'
        payload[:content][:moduleName] = repo_name
      else
        raise Puppet::Error "repo_type does not match one of: 'control', 'module'"
      end
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def list_puppet_environments(workspace, creds_name)
      params = {
        op: 'ListPuppetEnterpriseEnvironments',
        name: creds_name,
      }
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def list_pipelines_by_name(workspace, repo_name, pipeline_type, branch_name)
      params = {
        op: 'ListPipelinesByName',
        pipelineName: branch_name,
      }
      case pipeline_type
      when 'control'
        params[:controlRepoName] = repo_name
      when 'module'
        params[:moduleName] = repo_name
      else
        raise Puppet::Error "pipeline_type does not match one of: 'control', 'module'"
      end
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def post_provider_webhook(workspace, source_repo_name, source_repo_owner, source_repo_provider)
      payload = {
        op: 'PostProviderWebhook',
        content: {
          srcRepoName: source_repo_name,
          srcRepoOwner: source_repo_owner,
          srcRepoProvider: source_repo_provider,
        },
      }
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
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

    def create_agent_credentials
      endpoint = "#{HW_CONFIG_ENDPOINT}?op=CreateAgentCredentials"
      make_request(:get, endpoint)
    end

    def list_agent_credentials
      endpoint = "#{HW_CONFIG_ENDPOINT}?op=ListAgentCredentials"
      make_request(:get, endpoint)
    end

    def list_servers
      endpoint = "#{HW_CONFIG_ENDPOINT}?op=ListServers"
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
        when Net::HTTPInternalServerError
          if attempts < max_attempts
            Puppet.debug("Received #{response} error from #{service_url}, attempting to retry. (Attempt #{attempts} of #{max_attempts})")
            Kernel.sleep(10)
          else
            raise Puppet::Error, "Received #{attempts} server error responses from the CD4PE service at #{service_url}: #{response.code} #{response.body}"
          end
        when Net::HTTPBadRequest
          raise Puppet::Error, "Received failed response: #{response.code} #{response.body}"
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
