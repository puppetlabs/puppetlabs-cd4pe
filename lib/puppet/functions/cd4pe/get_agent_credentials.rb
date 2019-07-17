require 'puppet_x/puppetlabs/cd4pe_client'

Puppet::Functions.create_function(:'cd4pe::get_agent_credentials') do
  # need params for host, username, pass to initialize client
  dispatch :get_agent_credentials do
    param 'String', :host
    param 'String', :root_username
    param 'Sensitive', :root_password
  end

  def get_agent_credentials(host, root_username, root_password)
    client = PuppetX::Puppetlabs::CD4PEClient.new(host, root_username, root_password.unwrap)

    response = client.list_agent_credentials()
    has_agent_credentials = false
    if(response.code == '200')
      response_body = JSON.parse(response.body, symbolize_names: true)
      if(response_body.length > 0)
        first_active_creds = response_body.find { |creds| creds[:status] == "Active" }
        if(first_active_creds)
          return {
            :access_token => first_active_creds[:accessToken],
            :secret_key => first_active_creds[:secretKey]
          }
        end
      end
    else
      Puppet.debug("Problem getting agent credentials")
    end

    if(!has_agent_credentials)
      return create_new_credentials(client)
    end
  end


  def create_new_credentials(client)
    response = client.create_agent_credentials()
    if(response.code == '200')
      new_credentials = JSON.parse(response.body, symbolize_names: true)
      return {
        :access_token => new_credentials[:accessToken],
        :secret_key => new_credentials[:secretKey]
      }
    else
      Puppet.debug("Problem creating new agent credentials")
    end
  end

end
