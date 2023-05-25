# @api private
#
# Checks if the user has specified certs, key, and CRL for use by nginx for
# SSL termination. If no certs were provided, generates a key, self-signed
# cert, and CRL. In either case, uploads the artifacts to the location expected
# by the nginx container.
#
# @param config  Cd4pe::Config object with all config options
#
# @return This plan does not return anything
plan cd4pe::install::configure_ssl_termination(
  Cd4pe::Config $config,
) {
  # For now, assume that there is only one target associated with the UI role
  # Other parts of this plan, notably the `generate` function, will need
  # updating if this changes.
  $ui_host = $config['roles']['ui']['targets'][0]

  $cert_dir = file::join(cd4pe::bolt_project_files_dir(), 'cd4pe', 'browser_certs')
  run_command("mkdir -p ${cert_dir}", 'localhost')

  $cert_file_path = "${cert_dir}/cert_chain.pem"
  $key_file_path = "${cert_dir}/private_key.pem"
  $crl_file_path = "${cert_dir}/crl.pem"

  if file::exists($cert_file_path) and file::exists($key_file_path) and file::exists($crl_file_path) {
    $valid = cd4pe::verify_certs($cert_file_path, $key_file_path)
    if $valid {
      out::message('Valid browser certificates found.')
    } else {
      fail_plan('Invalid browser certificates or key provided. Aborting.', 'cd4pe/error')
    }
  } elsif file::exists($cert_file_path) or file::exists($key_file_path) or file::exists($crl_file_path) {
    $error_msg = @("EOT"/L)
      Incomplete browser certs found in ${cert_dir}. Please supply a cert chain, private key, and CRL, \
      or none of these to cause them to be generated.
      |EOT

    fail_plan($error_msg, 'cd4pe/error')
  } else {
    out::message('No browser certificates found, generating self-signed certificate chain.')

    $hostname = $config['roles']['backend']['services']['pipelinesinfra']['resolvable_hostname']
    cd4pe::generate_cert_chain($hostname, $cert_file_path, $key_file_path, $crl_file_path)
    out::message('Using generated browser certificates for SSL termination')
  }

  $upload_dir = '/etc/puppetlabs/cd4pe/browser_certs'
  run_command("mkdir -p ${upload_dir}", $ui_host, { '_run_as' => 'root' })

  out::message('Uploading browser certficate chain.')
  upload_file($cert_file_path, "${upload_dir}/cert_chain.pem", $ui_host, { '_run_as' => 'root' })

  out::message('Uploading browser private key.')
  upload_file($key_file_path, "${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })
  run_command("chmod 0400 ${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })

  out::message('Uploading browser crl.')
  upload_file($crl_file_path, "${upload_dir}/crl.pem", $ui_host, { '_run_as' => 'root' })
}
