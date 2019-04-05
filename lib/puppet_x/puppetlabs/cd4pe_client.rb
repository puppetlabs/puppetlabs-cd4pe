require 'net/http'
require 'uri'
require 'json'

# Provides a class for interacting with CD4PE's API
module PuppetX
  module Puppetlabs
    class CD4PEClient < Object
      attr_reader :config

      LOGIN_ENDPOINT = '/login'
      ROOT_AJAX_ENDPOINT = '/root/ajax'
      ROOT_ENDPOINT_SETTINGS = '/root/endpoint-settings'
      ROOT_STORAGE_SETTINGS = '/root/storage-settings'

      def initialize(hostname, username, password)
        uri = URI.parse(hostname)

        @config = {
          server: uri.host,
          port: uri.port || '8080',
          scheme: uri.scheme || 'http',
          username: username,
          password: password
        }

        set_cookie
      end

      def set_cookie
        content = {
          op: 'PfiLogin',
          content: {
            email: @config[:username],
            passwd: @config[:password]
          }
        }

        response = make_request(:post, LOGIN_ENDPOINT, content.to_json)
        if response.code == '200'
          @cookie = response.response['set-cookie'].split(';')[0]
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

      def get_root_config
        endpoint = "#{ROOT_AJAX_ENDPOINT}?op=GetRootConfiguration"
        make_request(:get, endpoint)
      end

      def cookie
        @cookie
      end

      def create_root_account
        payload = {
          op: 'CreateRootAccount',
          content: {
            email: @config[:username],
            passwd: @config[:password]
          }
        }
        make_request(:post, '/root-account', payload.to_json)
      end

      def save_license(license)
        payload = {
          op: 'RootSavePfiLicense',
          content: license
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
            }
          }
        }
        make_request(:post, ROOT_ENDPOINT_SETTINGS, payload.to_json)
      end

      def save_storage_settings(provider, endpoint, bucket, prefix, access_key=nil, secret_key='')
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
              osCredSecret: secret_key
            }
          }
        }
        make_request(:post, ROOT_STORAGE_SETTINGS, payload.to_json)
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
            }
          }
        }
        make_request(:post, ROOT_AJAX_ENDPOINT, payload.to_json)
      end

      private

      def make_request(type, api_url, payload="")
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
end
