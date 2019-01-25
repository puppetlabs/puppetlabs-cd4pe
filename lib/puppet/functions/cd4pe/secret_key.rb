require 'securerandom'
Puppet::Functions.create_function(:'cd4pe::secret_key') do
  def secret_key
    SecureRandom.base64(n = 16)
  end
end
