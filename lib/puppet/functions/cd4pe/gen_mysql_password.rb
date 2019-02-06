require 'securerandom'
Puppet::Functions.create_function(:'cd4pe::gen_mysql_password') do
  def gen_mysql_password
    SecureRandom.hex(n = 32)
  end
end
