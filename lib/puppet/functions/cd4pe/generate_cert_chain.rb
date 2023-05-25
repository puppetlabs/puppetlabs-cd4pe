require 'openssl'
require 'resolv'

Puppet::Functions.create_function(:'cd4pe::generate_cert_chain') do

  dispatch :generate do
    param 'String', :hostname
    param 'String', :cert_file_dest
    param 'String', :key_file_dest
    param 'String', :crl_file_dest
  end

  def generate(hostname, cert_file_dest, key_file_dest, crl_file_dest)
    ca_key = create_private_key
    ca_cert = create_self_signed_ca(ca_key, "/CN=CD4PE CA: #{hostname}")
    ca_crl = create_crl_for(ca_cert, ca_key)

    host_key = create_private_key
    host_csr = create_csr(host_key, "/CN=#{hostname}")
    host_cert = sign(hostname, ca_key, ca_cert, host_csr)

    File.open(cert_file_dest, 'w') do |f|
      f.puts(host_cert)
      f.puts(ca_cert)
    end

    File.open(crl_file_dest, 'w') do |f|
      f.puts(ca_crl)
    end

    # Ensure this file at least has minimum perms, and we may eventually
    # want to store this key encrypted instead
    File.open(key_file_dest, 'w') do |f|
      f.puts(host_key)
      File.chmod(0400, key_file_dest)
    end
  end

  PRIVATE_KEY_LENGTH = 4096
  FIFTEEN_YEARS_SECONDS = 15 * 365 * 24 * 60 * 60

  SSL_SERVER_CERT_OID = "1.3.6.1.5.5.7.3.1"

  CA_EXTENSIONS = [
    ["basicConstraints", "CA:TRUE", true],
    ["keyUsage", "keyCertSign, cRLSign", true],
    ["subjectKeyIdentifier", "hash", false],
    ["authorityKeyIdentifier", "keyid:always", false]
  ]
  SERVER_EXTENSIONS = [
    ["keyUsage", "digitalSignature,keyEncipherment", true],
    ["subjectKeyIdentifier", "hash", false],
    ["extendedKeyUsage", "#{SSL_SERVER_CERT_OID}", true],
  ]

  DEFAULT_SIGNING_DIGEST = OpenSSL::Digest::SHA256.new

  def create_private_key
    OpenSSL::PKey::RSA.new(PRIVATE_KEY_LENGTH)
  end

  def create_self_signed_ca(key, name)
    cert = OpenSSL::X509::Certificate.new

    cert.public_key = key.public_key
    cert.subject = OpenSSL::X509::Name.parse(name)
    cert.issuer = cert.subject
    cert.version = 2
    cert.serial = rand(2**128)

    not_before = just_now
    cert.not_before = not_before
    cert.not_after = not_before + FIFTEEN_YEARS_SECONDS

    ext_factory = extension_factory_for(cert, cert)
    CA_EXTENSIONS.each do |ext|
      extension = ext_factory.create_extension(*ext)
      cert.add_extension(extension)
    end

    cert.sign(key, DEFAULT_SIGNING_DIGEST)

    cert
  end

  def create_csr(key, name)
    csr = OpenSSL::X509::Request.new

    csr.public_key = key.public_key
    csr.subject = OpenSSL::X509::Name.parse(name)
    csr.version = 2
    csr.sign(key, DEFAULT_SIGNING_DIGEST)

    csr
  end

  def sign(hostname, ca_key, ca_cert, csr)
    cert = OpenSSL::X509::Certificate.new

    cert.public_key = csr.public_key
    cert.subject = csr.subject
    cert.issuer = ca_cert.subject
    cert.version = 2
    cert.serial = rand(2**128)

    not_before = just_now
    cert.not_before = not_before
    cert.not_after = not_before + FIFTEEN_YEARS_SECONDS

    ext_factory = extension_factory_for(ca_cert, cert)
    SERVER_EXTENSIONS.each do |ext|
      extension = ext_factory.create_extension(*ext)
      cert.add_extension(extension)
    end

    if (hostname =~ Resolv::IPv4::Regex) || (hostname =~ Resolv::IPv6::Regex)
      type_string = 'IP'
    else
      type_string = 'DNS'
    end
    alt_names_ext = ext_factory.create_extension("subjectAltName", "#{type_string}:#{hostname}", false)
    cert.add_extension(alt_names_ext)

    cert.sign(ca_key, DEFAULT_SIGNING_DIGEST)

    cert
  end

  # Returns a Time object for one minute ago,
  # to give some tolerance for clock skew
  def just_now
    Time.now - 60
  end

  def create_crl_for(cert, key)
    crl = OpenSSL::X509::CRL.new
    crl.version = 1
    crl.issuer = cert.subject

    ef = extension_factory_for(cert)
    crl.add_extension(ef.create_extension(["authorityKeyIdentifier", "keyid:always", false]))
    crl.add_extension(OpenSSL::X509::Extension.new("crlNumber", OpenSSL::ASN1::Integer(0)))

    crl.last_update = just_now
    crl.next_update = just_now + FIFTEEN_YEARS_SECONDS
    crl.sign(key, DEFAULT_SIGNING_DIGEST)

    crl
  end

  def extension_factory_for(ca, cert = nil)
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.issuer_certificate  = ca
    ef.subject_certificate = cert if cert

    ef
  end
end
