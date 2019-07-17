require 'puppet_x/puppetlabs/cd4pe_client'

Puppet::Functions.create_function(:'cd4pe::has_job_hardware') do
  # need params for host, username, pass to initialize client
  dispatch :has_job_hardware do
    param 'String', :host
    param 'String', :root_username
    param 'Sensitive', :root_password
  end

  def has_job_hardware(host, root_username, root_password)
    client = PuppetX::Puppetlabs::CD4PEClient.new(host, root_username, root_password.unwrap)

    response = client.list_servers
    if(response == '200')
      response_body = JSON.parse(response.body, symbolize_names: true)
      return response_body[:rows].length > 0
    else
      Puppet.debug("Unable to find servers")
      return false
    end
  end
end
