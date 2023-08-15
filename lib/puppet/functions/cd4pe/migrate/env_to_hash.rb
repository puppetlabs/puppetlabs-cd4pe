Puppet::Functions.create_function(:'cd4pe::migrate::env_to_hash') do
  dispatch :env_to_hash do
    param 'Array[Hash]', :env_json
    return_type 'Hash'
  end

  def env_to_hash(env_json)
    env_hash = {}
    env_json.each do |env_var|
      # ignore vars whose values are from secrets
      if env_var['value']
        env_hash[env_var['name']] = env_var['value']
      end
    end
    env_hash
  end
end
