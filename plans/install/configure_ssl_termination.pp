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

  $upload_dir = '/etc/puppetlabs/cd4pe/browser_certs'

  if(!empty($config['ssl']['cert_chain']) and !empty($config['ssl']['private_key'])) {
    $cert_chain = $config['ssl']['cert_chain']
    $private_key = $config['ssl']['private_key']
    $crl = $config['ssl']['crl']

    out::message("Validating user-provided certificate from hiera data. ${cert_chain} ${private_key} ${crl}")
    $valid = cd4pe::verify_certs($cert_chain, $private_key.unwrap)
    if $valid {
      out::message('Valid browser certificates found.')
    } else {
      fail_plan('Invalid browser certificates or key provided. Aborting.', 'cd4pe/error')
    }
    run_command("mkdir -p ${upload_dir}", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser certficate chain.')
    write_file($cert_chain, "${upload_dir}/cert_chain.pem", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser private key.')
    write_file($private_key.unwrap, "${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })
    run_command("chmod 0400 ${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser crl.')
    write_file($crl, "${upload_dir}/crl.pem", $ui_host, { '_run_as' => 'root' })
  } else {
    out::message('No user-provided browser certificates found, generating self-signed certificate chain.')

    $hostname = $config['roles']['backend']['services']['pipelinesinfra']['resolvable_hostname']
    $generated = cd4pe::generate_cert_chain($hostname)
    out::message('Using generated browser certificates for SSL termination')

    run_command("mkdir -p ${upload_dir}", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser certficate chain.')
    write_file($generated['cert_chain'], "${upload_dir}/cert_chain.pem", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser private key.')
    write_file($generated['private_key'], "${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })
    run_command("chmod 0400 ${upload_dir}/private_key.pem", $ui_host, { '_run_as' => 'root' })

    out::message('Uploading browser crl.')
    write_file($generated['crl'], "${upload_dir}/crl.pem", $ui_host, { '_run_as' => 'root' })
  }
}
