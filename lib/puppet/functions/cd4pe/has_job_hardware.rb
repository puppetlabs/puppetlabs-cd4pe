require 'puppet_x/puppetlabs/cd4pe_client'

Puppet::Functions.create_function(:'cd4pe::job_hardware?') do
  dispatch :job_hardware? do
    param 'String', :host
    param 'String', :root_username
    param 'Sensitive', :root_password
  end

  def job_hardware?(host, root_username, root_password)
    client = PuppetX::Puppetlabs::CD4PEClient.new(host, root_username, root_password.unwrap)

    response = client.list_servers
    if response.code == '200'
      response_body = JSON.parse(response.body, symbolize_names: true)
      return !response_body[:rows].empty?
    else
      Puppet.debug("Unable to find servers, response code #{response.code}")
      return false
    end
  rescue => exception
    Puppet.debug("Unable to contact server at #{host} to get job hardware, moving on.", exception.backtrace)
  end
end
