require 'securerandom'
Puppet::Functions.create_function(:'cd4pe::secure_random') do
  dispatch :secure_random do
    param 'Integer', :length
    return_type 'String'
  end
  def secure_random(length)
    SecureRandom.base64(length)
  end
end
