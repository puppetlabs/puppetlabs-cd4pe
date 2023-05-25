require 'net/http'
require 'openssl'
# Hits CD4PE's status api endpoint to check if everything is up and running. This endpoint
# will verify that we can route properly from the UI container to the backend, and that the backend is
# up and running. If the backend is up and running, that usually means we have access to the database.
# Will retry 15 times, with 5 seconds in between checks. This should give plenty of time for the backend
# database migrations to run until we move them into their own lifecycle event.
Puppet::Functions.create_function(:'cd4pe::status_check') do
  # @param resolvable_hostname The resolvable hostname to check
  # @return boolean - true if the status api endpoint returns healthy, false if not
  dispatch :status_check do
    param 'String', :resolvable_hostname
    return_type 'Boolean'
  end

  def status_check(resolvable_hostname)
    uri = URI("https://#{resolvable_hostname}/status")
    max_attempts = 15
    sleep_duration_secs = 5

    call_function('out::message', "Checking connectivity from bolt runner to #{uri}")
    for i in 1..max_attempts do
      attempt = "Attempt #{i} of #{max_attempts}:"
      begin
        Net::HTTP.start(uri.host,
        uri.port,
        :use_ssl => true,
        :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
          request = Net::HTTP::Get.new(uri)
          response = https.request(request)
          if response.kind_of?(Net::HTTPSuccess)
            if 'healthy' == response.body.downcase
              call_function('out::message', "#{attempt} Received healthy response, all services up and running.")
              return true
            else
              call_function('out::message', "#{attempt} Reached #{uri}, but did not receive healthy status response. Waiting another 5 seconds.")
            end
          else
            call_function('out::message', "#{attempt} Error Reaching #{uri}. Got http code #{response.code}. Waiting another 5 seconds and trying again.")
          end
        end
      rescue StandardError => e
        call_function('out::message', "#{attempt} Error Reaching #{uri}. #{e.message}. Waiting another 5 seconds and trying again.")
      end

      sleep sleep_duration_secs
    end

    return false
  end
end