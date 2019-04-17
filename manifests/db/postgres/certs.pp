class cd4pe::db::postgres::certs(
  String $pg_user,
  String $pg_group,
  String $pg_cert_dir,
  String $client_ca_cert,
  String $client_cert,
  String $client_private_key,
){

  $certname           = $trusted['certname']
  $cert_dir           = "${cd4pe::db::data_root_dir}/certs"
  $target_ca_cert     = "${cert_dir}/ca.pem"
  $target_client_cert = "${cert_dir}/client_cert.pem"
  $pk8_file           = "${cert_dir}/client_private_key.pk8"
  $ssl_db_env         = "${cd4pe::db::data_root_dir}/ssl_db_env"

  # Copy the local agent certs for the container to use, and mount them
  Docker::Run <| title == 'cd4pe' |> {
    volumes    +> ["${cert_dir}:/certs"],
    env_file   +> [$ssl_db_env],
  }

  file { $cert_dir:
    ensure => directory,
    owner  => undef,
    group  => undef,
    mode   => '0600',
  }

  file { $target_ca_cert:
    ensure => file,
    source => $client_ca_cert,
    owner  => undef,
    group  => undef,
    mode   => '0400',
  }

  file { $target_client_cert:
    ensure => file,
    source => $client_cert,
    owner  => undef,
    group  => undef,
    mode   => '0400',
  }


  exec { $pk8_file:
    path    => [ '/opt/puppetlabs/puppet/bin', $::facts['path'] ],
    command => "openssl pkcs8 -topk8 -inform PEM -outform DER -in ${client_private_key} -out ${pk8_file} -nocrypt",
    onlyif  => "test ! -e '${pk8_file}' -o '${pk8_file}' -ot '${client_private_key}'",
  }

  file { $pk8_file:
    ensure    => present,
    owner     => undef,
    group     => undef,
    mode      => '0400',
    show_diff => false,
  }

  $ssl_db_data = {
    db_ssl_root_cert => $target_ca_cert,
    db_ssl_cert      => $target_client_cert,
    db_ssl_key       => $pk8_file
  }

  file { "${cd4pe::db::data_root_dir}/ssl_db_env":
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/app_db_ssl_env.epp', $ssl_db_data),
  }

  # Copy the client certs to postgres
  file { $pg_cert_dir:
    ensure => directory,
    owner  => $pg_user,
    group  => $pg_group,
    mode   => '0600',
  }

  file { "${pg_cert_dir}/${certname}.cert.pem":
    ensure => file,
    source => $client_cert,
    owner  => $pg_user,
    group  => $pg_group,
    mode   => '0400',
  }

  file { "${pg_cert_dir}/${certname}.private_key.pem":
    ensure => file,
    source => $client_private_key,
    owner  => $pg_user,
    group  => $pg_group,
    mode   => '0400',
  }
}
