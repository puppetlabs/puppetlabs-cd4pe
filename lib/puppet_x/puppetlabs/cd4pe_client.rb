require 'puppet_x'
require 'net/http'
require 'uri'
require 'json'
require 'base64'

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

    def initialize(hostname, email = nil, password = nil, base64_cacert = nil, insecure_https = false)
      uri = URI.parse(hostname)

      @config = {
        server: uri.host,
        port: uri.port,
        scheme: uri.scheme || 'https',
        base64_cacert: base64_cacert,
        insecure_https: insecure_https,
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

    def generate_trial_license
      # generate the trial license
      response = make_request(:get, '/generate-trial-license?op=GenerateTrialLicense')
      license = JSON.parse(response.body)

      # save the trial license
      payload = {
        op: 'SavePfiLicense', # Note: endpoint is different from the save_license endpoint
        content: license,
      }
      make_request(:post, '/root/license', payload.to_json)
    end

    def create_workspace(workspace, for_user)
      payload = {
        op: 'CreateWorkspace',
        content: {
          workspaceName: workspace,
        },
      }
      make_request(:post, "/#{for_user}/ajax", payload.to_json)
    end

    def add_vcs_integration(provider, workspace, provider_specific)
      case provider
      when 'gitlab'
        op = 'ConnectGitLab'
      when 'GHE'
        op = 'ConnectGitHubEnterprise'
      when 'bbs'
        op = 'ConnectBitbucketServer'
      end

      payload = { op: op }
      payload['content'] = provider_specific

      make_request(:post, "/#{workspace}/ajax", payload.to_json)
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

    def discover_pe_credentials(workspace, creds_name, pe_username, pe_password, pe_token, pe_console_host, token_lifetime)
      payload = {
        op: 'DiscoverPuppetEnterpriseCredentials',
        content: {
          consoleHost: pe_console_host,
          name: creds_name,
          username: pe_username,
          password: pe_password,
          token: pe_token,
          lifetime: token_lifetime,
          puppetServerCertificate: '',
          puppetServerEndpoint: '',
          puppetServerPrivateKey: '',
        },
      }
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def add_repo(workspace, source_control, repo_org, source_repo_name, repo_name, repo_type)
      org_res = list_source_orgs(workspace, source_control)
      if org_res.code != '200'
        raise Puppet::Error, "Error while listing source orgs: #{org_res.body}"
      end

      source_orgs = JSON.parse(org_res.body, symbolize_names: true)
      matched_source_orgs = source_orgs.select { |org| repo_org.casecmp(org[:organization]).zero? }

      if matched_source_orgs.empty?
        raise Puppet::Error, "Could not find repo orgs for name: #{repo_org}"
      end
      if matched_source_orgs.length > 1
        raise Puppet::Error, "Found multiple repo orgs for name: #{repo_org}. Org names must be unique when referenced here."
      end

      repos_res = search_source_repos(workspace, source_control, matched_source_orgs[0], source_repo_name)
      if repos_res.code != '200'
        raise Puppet::Error, "Error while searching for repository: #{repos_res.body}"
      end
      source_repos = JSON.parse(repos_res.body, symbolize_names: true)
      if source_repos.empty?
        raise Puppet::Error, "Could not find source repo for name: #{source_repo_name}"
      end
      matched_source_repos = source_repos.select { |repo| source_repo_name.casecmp(repo[:repoName]).zero? }
      if matched_source_repos.length > 1
        raise Puppet::Error, "Found multiple repositories for repository name: #{repo_name}"
      end
      # There should only be one repo from the search
      source_repo = matched_source_repos[0]
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
          srcRepoDisplayOwner: source_repo[:owner],
          srcRepoId: source_repo[:repoId],
          srcRepoName: source_repo[:repoName],
          srcRepoOwner: source_repo[:owner],
          # The search API returns the value of the provider as an lowercase string. It needs to be uppercase when creating a control repo.
          srcRepoProvider: source_repo[:provider].upcase,
        },
      }
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def search_source_repos(workspace, source_control, repo_org, repo_name)
      params = {
        op: 'SearchSourceRepos',
        provider: source_control,
        search: repo_name,
      }
      unless repo_org[:personalOrg]
        params[:org] = repo_org[:organization]
      end
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def list_source_orgs(workspace, provider)
      params = {
        op: 'ListSourceOrgs',
        provider: provider,
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

    def set_pipelines_as_code_branch(workspace, repo_type, repo_name, branch_name)
      payload = {
        op: 'SetPipelinesAsCodeBranch',
        content: {
          get_repo_payload_key(repo_type) => repo_name,
          branchName: branch_name,
        },
      }
      make_request(:post, get_ajax_endpoint(workspace), payload.to_json)
    end

    def get_pipelines_as_code_error(workspace, repo_type, repo_name)
      params = {
        op: 'GetPipelinesAsCodeError',
        get_repo_payload_key(repo_type) => repo_name,
      }
      api_uri = URI(get_ajax_endpoint(workspace))
      api_uri.query = URI.encode_www_form(params)
      make_request(:get, api_uri.to_s)
    end

    def create_pipeline(workspace, repo_name, repo_branch, pipeline_type)
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
          pipelineName: repo_branch,
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

    def get_pipeline_for_branch(workspace, repo_name, pipeline_type, branch_name)
      pipelines_by_name_res = list_pipelines_by_name(workspace, repo_name, pipeline_type, branch_name)
      pipelines_by_name = JSON.parse(pipelines_by_name_res.body, symbolize_names: true)
      matched_pipelines = pipelines_by_name.select { |pipeline| branch_name.casecmp(pipeline[:name]).zero? }
      if matched_pipelines.empty?
        raise Puppet::Error, "Could not find pipeline for #{pipeline_type} repository: #{repo_name} with branch name: #{branch_name}."
      end
      if matched_pipelines.length > 1
        raise Puppet::Error, "Found multiple pipelines for #{pipeline_type} repository: #{repo_name} with branch name: #{branch_name}."
      end
      matched_pipelines[0]
    end

    def add_deployment_to_stage(workspace,
                                repo_name,
                                repo_type,
                                branch_name,
                                pe_creds_name,
                                node_group_name,
                                stage_name,
                                add_stage_after,
                                autopromote,
                                trigger_condition)
      current_pipeline = get_pipeline_for_branch(workspace, repo_name, repo_type, branch_name)
      puppet_environment_res = list_puppet_environments(workspace, pe_creds_name)
      puppet_environments = JSON.parse(puppet_environment_res.body, symbolize_names: true)
      matched_environments = puppet_environments.select { |env| node_group_name.casecmp(env[:name]).zero? }
      if matched_environments.empty?
        raise Puppet::Error, "Could not find node group for name: #{node_group_name}"
      end
      if matched_environments.length > 1
        raise Puppet::Error, "Found multiple node groups for name: #{node_group_name}. Assign the node groups unique names and try again."
      end
      environment = matched_environments[0]
      new_deployment = {
        peModuleDeploymentTemplate: {
          settings: {
            doCodeDeploy: true,
            environment: {
              nodeGroupBranch: environment[:environment],
              nodeGroupId: environment[:id],
              nodeGroupName: environment[:name],
              peCredentialsId: {
                domain: current_pipeline[:projectId][:domain],
                name: pe_creds_name,
              },
            },
            moduleId: {
              domain: current_pipeline[:projectId][:domain],
              name: repo_name,
            },
          },
        },
      }
      new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_deployment, stage_name, add_stage_after, autopromote, trigger_condition)
      new_pipeline_res = upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], new_stages)
      JSON.parse(new_pipeline_res.body, symbolize_names: true)
    end

    def add_job_to_stage(workspace,
                         repo_name,
                         repo_type,
                         branch_name,
                         job_name,
                         stage_name,
                         add_stage_after,
                         autopromote,
                         trigger_condition)
      current_pipeline = get_pipeline_for_branch(workspace, repo_name, repo_type, branch_name)
      job_template_res = list_job_templates(workspace)
      job_templates = JSON.parse(job_template_res.body, symbolize_names: true)

      matched_job_templates = job_templates[:rows].select { |template| job_name.casecmp(template[:name]).zero? }
      if matched_job_templates.empty?
        raise Puppet::Error, "Could not find job for name: #{job_name}"
      end
      if matched_job_templates.length > 1
        raise Puppet::Error, "Found multiple jobs for name: #{job_name}. Give the job a unique name and try again."
      end
      new_job_destination = { vmJobTemplateId: matched_job_templates[0][:id] }
      new_stages = CD4PEPipelineUtils.add_destination_to_stage(current_pipeline[:stages], new_job_destination, stage_name, add_stage_after, autopromote, trigger_condition)
      new_pipeline_res = upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], new_stages)
      JSON.parse(new_pipeline_res.body, symbolize_names: true)
    end

    def add_pr_gate_to_stage(workspace, repo_name, repo_type, branch_name, stage_name)
      current_pipeline = get_pipeline_for_branch(workspace, repo_name, repo_type, branch_name)
      current_stages = current_pipeline[:stages]
      existing_stage_idx = CD4PEPipelineUtils.get_stage_index_by_name(current_stages, stage_name)
      current_stages[existing_stage_idx][:pipelineGate] = {
        projectPipelineGateType: 'PULLREQUEST',
        stageNum: current_stages[existing_stage_idx][:stageNum],
      }
      if current_stages[existing_stage_idx].key?(:triggerOn)
        current_stages[existing_stage_idx][:pipelineGate][:triggerOn] = current_stages[existing_stage_idx][:triggerOn]
      end
      if current_stages[existing_stage_idx].key?(:triggerCondition)
        current_stages[existing_stage_idx][:pipelineGate][:triggerCondition] = current_stages[existing_stage_idx][:triggerCondition]
      end

      upsert_pipeline_stages(workspace, repo_name, repo_type, current_pipeline[:id], current_stages)
      pr_build_triggers = ['Commit', 'PullRequest']
      build_trigger_res = set_pipeline_auto_build_triggers(workspace, repo_name, repo_type, current_pipeline[:id], current_pipeline[:name], pr_build_triggers)
      set_is_build_pr_allowed(workspace, repo_name, repo_type, false)
      JSON.parse(build_trigger_res.body, symbolize_names: true)
    end

    def post_provider_webhook(workspace, repo)
      repo_name = repo[:srcRepoName]
      # This is necessary due to business logic living in the UI code
      if repo[:srcRepoProvider].casecmp?('gitlab')
        repo_name = repo[:srcRepoId]
      end
      payload = {
        op: 'PostProviderWebhook',
        content: {
          srcRepoName: repo_name,
          srcRepoOwner: repo[:srcRepoOwner],
          srcRepoProvider: repo[:srcRepoProvider],
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

    def get_repo_payload_key(repo_type)
      case repo_type
      when 'control'
        'controlRepoName'
      when 'module'
        'moduleName'
      else
        raise Puppet::Error "repo_type does not match one of: 'control', 'module'"
      end
    end

    def make_request(type, api_url, payload = '')
      connection = Net::HTTP.new(@config[:server], @config[:port])
      headers = {
        'Content-Type' => 'application/json',
        'Cookie' => @cookie,
      }

      connection.use_ssl = true

      if @config[:insecure_https]
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      unless @config[:base64_cacert].nil?
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        decoded_cert = Base64.decode64(@config[:base64_cacert])
        certificate = OpenSSL::X509::Certificate.new(decoded_cert)
        store.add_cert(certificate)
        connection.cert_store = store
      end

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
