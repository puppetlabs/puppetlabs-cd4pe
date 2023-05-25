require 'openssl'
# Encrypts a given string using PKCS7 and aes-256-cbc as the cipher.
#
# This is a copy of the logic from the PKCS7 task:
# https://github.com/puppetlabs/puppetlabs-pkcs7/blob/main/tasks/secret_encrypt.rb
#
# This function exists instead of calling a task so to prevent the secret from
# leaving the calling code.
Puppet::Functions.create_function(:'cd4pe::encrypt') do
  # @param data A puppet Sensitive datatype with the value to encrypt
  # @param public_key_path a relative file path to the public key
  # @return A string ready to go into hiera-eyaml
  dispatch :encrypt do
    param 'Sensitive[String]', :value
    optional_param 'String', :public_key_path
    return_type 'String[1]'
  end

  def encrypt(value, public_key_path='keys/public_key.pkcs7.pem')
    boltdir = call_function('cd4pe::bolt_project_dir')
    public_key_path = File.expand_path(public_key_path, boltdir)
    public_key      = OpenSSL::X509::Certificate.new(File.read(public_key_path))
    Puppet.debug("Using public key: #{public_key_path}")

    # Initialize the cipher
    cipher = OpenSSL::Cipher.new('aes-256-cbc')

    # Encrypt plaintext
    raw = OpenSSL::PKCS7.encrypt([public_key], value.unwrap, cipher, OpenSSL::PKCS7::BINARY).to_der

    # Encode the raw ciphertext
    "ENC[PKCS7,#{Base64.encode64(raw).strip}]"
  end
end
