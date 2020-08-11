# @summary Deprovisions an existing Continuous Delivery for PE installation
# @param db_provider
#   Which database provider your existing installation is using: mysql or postgres
#
class cd4pe::deprovision (
  Enum['mysql', 'postgres'] $db_provider = 'postgres',
  Optional[String] $db_host              = undef,
  String $cd4pe_image                    = 'puppet/continuous-delivery-for-puppet-enterprise',
  String $cd4pe_version                  = '3.x'
){
  include docker

  warning('Beginning with version 3.0.0 of this module, we no longer support the installation of CD4PE or management of databases.')

  $data_root_dir = '/etc/puppetlabs/cd4pe'

  if $db_provider == undef {
    # Check if the customer is using a mysql db from a previous install
    $cd4pe_docker_facts = fact('docker.network.cd4pe.Containers')
    if !empty($cd4pe_docker_facts) {
      $cd4pe_mysql = $cd4pe_docker_facts.filter |$k, $v| { $v['Name'] == 'cd4pe_mysql' }.values
      if !empty($cd4pe_mysql) {
        $effective_db_provider = 'mysql'
      } else {
        $effective_db_provider = 'postgres'
      }
    } else {
      $effective_db_provider = 'postgres'
    }
  } else {
    $effective_db_provider = $db_provider
  }

  debug('Doing cleanup of CD4PE resources.')

  file { [$data_root_dir,
          "${data_root_dir}/secret_key",
          "${data_root_dir}/env",
          "${data_root_dir}/cd4pe_db_password",
          "${data_root_dir}/db_env"] :
    ensure => absent,
  }
  if($effective_db_provider == 'mysql'){
    docker_network { 'cd4pe':
      ensure  => absent,
    }

    file{["${data_root_dir}/mysql_password", "${data_root_dir}/mysql_env"]:
      ensure => absent,
    }

    if($db_host == undef){
      $host = 'cd4pe_mysql'
    } else {
      $host = $db_host
    }

    docker::run { $host:
      ensure => absent,
      image  => 'mysql:5.7'
    }
  } elsif($effective_db_provider == 'postgres'){
    $pgsqldir    = '/opt/puppetlabs/server/data/postgresql'
    $pg_version   = '9.6'
    $pgsql_data_dir = "${pgsqldir}/${pg_version}/data"
    $certname           = $trusted['certname']
    $cert_dir           = "${data_root_dir}/certs"
    $target_ca_cert     = "${cert_dir}/ca.pem"
    $target_client_cert = "${cert_dir}/client_cert.pem"
    $pk8_file           = "${cert_dir}/client_private_key.pk8"
    $ssl_db_env         = "${data_root_dir}/ssl_db_env"
    $pg_ident_conf_path = "${pgsql_data_dir}/pg_ident.conf"
    $postgres_cert_dir = "${pgsql_data_dir}/certs"

    if ($facts['os']['family'] == 'RedHat') and ($facts['os']['release']['major'] !~ '^7') {
      file { '/etc/sysconfig/pgsql':
        ensure  => absent,
      }
    }

    file {[$pgsqldir, "${pgsqldir}/${pg_version}" ]:
      ensure  => absent,
    }

    file { [$cert_dir,
            $target_ca_cert,
            $target_client_cert,
            $pk8_file, $ssl_db_env,
            $postgres_cert_dir]:
      ensure => absent,
    }
  }

  docker::run {'cd4pe':
    ensure => absent,
    image  => "${cd4pe_image}:${cd4pe_version}"
  }
}
