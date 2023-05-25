require 'openssl'

Puppet::Functions.create_function(:'cd4pe::verify_certs') do

  dispatch :verify do
    param 'String', :cert_chain_file
    param 'String', :key_file
  end

  def verify(cert_chain_file, key_file)
    contents = File.read(cert_chain_file)
    cert_texts = contents.scan(/-----BEGIN CERTIFICATE-----(?:.|\n)+?-----END CERTIFICATE-----/)

    if cert_texts.empty?
      Puppet.err "No certificates found in #{cert_chain_file}. Please ensure file contains PEM encoded certificates, with the leaf cert first."
      return false
    end

    certs = cert_texts.map { |text| OpenSSL::X509::Certificate.new(text) }

    host_cert = certs.shift
    store = OpenSSL::X509::Store.new
    certs.each { |cert| store.add_cert(cert) }

    if !store.verify(host_cert)
      Puppet.err "Invalid certificate chain provided in #{cert_chain_file}. Please ensure file contains a valid PEM encoded certificate chain, with the leaf cert first."
      return false
    end

    key = OpenSSL::PKey::RSA.new File.read(key_file)
    if !host_cert.check_private_key(key)
      Puppet.err "Key provided in #{key_file} does not match provided leaf cert."
      return false
    else
      return true
    end
  end
end
