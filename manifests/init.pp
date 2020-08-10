# @summary Init class for puppetlabs-cd4pe. As of version 3.0.0, installation and configuration of CD4PE 
#   and its parts are no longer supported, this module only serves to configure Impact Analysis on PE and cleanup older CD4PE installations.
# @param cleanup
#   When set to true, runs through all resources created by the cd4pe module (version < 2.0.1) and makes sure
#   they are no longer present.
class cd4pe (
  Integer $agent_service_port                                 = 7000,
  Boolean $analytics                                          = true,
  Boolean $enable_repo_caching                                = false,
  Optional[Integer[1]] $puppetdb_connection_timeout_sec       = undef,
  Integer $backend_service_port                               = 8000,
  Integer $query_service_port                                 = 8888,
  Array[String] $cd4pe_docker_extra_params                    = [],
  String $cd4pe_image                                         = 'puppet/continuous-delivery-for-puppet-enterprise',
  Variant[Enum['latest','3.x'], String] $cd4pe_version        = '3.x',
  Optional[String[1]] $db_host                                = undef,
  Optional[String[1]] $db_name                                = undef,
  Optional[Sensitive[String[1]]] $db_pass                     = undef,
  Optional[Integer] $db_port                                  = undef,
  Optional[String[1]] $db_prefix                              = undef,
  Optional[Enum['mysql','postgres']] $db_provider             = undef,
  String $db_user                                             = 'cd4pe',
  Boolean $manage_database                                    = true,
  Boolean $manage_pe_host_mapping                             = true,
  String $resolvable_hostname                                 = "http://${trusted['certname']}",
  Integer $web_ui_port                                        = 8080,
  Integer $web_ui_ssl_port                                    = 8443,
  Optional[String[1]] $cd4pe_network_subnet                   = undef,
  Optional[String[1]] $cd4pe_network_gateway                  = undef,
  Boolean $cleanup                                            = false,
){

  if ( $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '8' ){
    fail('You cannot use the cd4pe module to install on EL 8')
  }

  $compiling_server_osfamily = cd4pe::compiling_server_osfamily()
  $compiling_server_operatingsystemmajrelease = cd4pe::compiling_server_operatingsystemmajrelease()
  if ( $compiling_server_osfamily != $facts['os']['family'] or
      $compiling_server_operatingsystemmajrelease != $facts['os']['release']['major']){
    fail("The PE Master OS '${compiling_server_osfamily} ${compiling_server_operatingsystemmajrelease}' must match the cd4pe agent node OS '${facts['os']['family']} ${facts['os']['release']['major']}'")
  }

  # Restrict to linux only?
  include docker

  warning('Beginning with version 3.0.0 of this module, we no longer support the installation of CD4PE or management of databases.')

  $data_root_dir = '/etc/puppetlabs/cd4pe'

  if $manage_database  {
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
  }

  if($cleanup) {
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
        subnet  => $cd4pe_network_subnet,
        gateway => $cd4pe_network_gateway,
      }

      file{["${data_root_dir}/mysql_password", "${data_root_dir}/mysql_env"]:
        ensure => absent,
      }

      if($db_host == undef){
        $host = 'cd4pe_mysql'
      } else {
        $host = $db_host
      }

      # docker::run { $host:
      #   ensure => absent
      # }
    } elsif($effective_db_provider == 'postgres'){
      $pgsqldir    = '/opt/puppetlabs/server/data/postgresql'
      $pg_version   = '9.6'
      $pgsql_data_dir = "${pgsqldir}/${pg_version}/data"
      $certname           = $trusted['certname']
      $cert_dir           = "${cd4pe::db::data_root_dir}/certs"
      $target_ca_cert     = "${cert_dir}/ca.pem"
      $target_client_cert = "${cert_dir}/client_cert.pem"
      $pk8_file           = "${cert_dir}/client_private_key.pk8"
      $ssl_db_env         = "${cd4pe::db::data_root_dir}/ssl_db_env"
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

      class { 'pe_postgresql::server':
        package_ensure => absent,
      }
      class { 'pe_postgresql::client':
        package_ensure => absent,
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
      ensure  => absent,
      image   => "${cd4pe_image}:${cd4pe_version}",
      volumes => ['cd4pe-object-store:/disk'],
    }

    $repo_name = 'cd4pe'

    case $facts['platform_tag'] {
      /^(el|redhatfips)-[67]-x86_64$/: {
        yumrepo { $repo_name:
          ensure  => absent,
          descr   => 'Puppet Labs PE Packages $releasever - $basearch', # don't want to interoplate those - they are yum strings
          enabled => true,
        }
      }
      /^ubuntu-(12|14|16|18)\.04-amd64$/: {

        # File resource defaults from the master class are getting applied here due to PUP-3692,
        # need to be explicit with owner/group, otherwise they get set to pe-puppet.
        file { "/etc/apt/apt.conf.d/90${repo_name}":
          ensure => absent,
          notify => Exec['pe_apt_update'],
        }

        file { "/etc/apt/sources.list.d/${repo_name}.list":
          ensure => file,
          notify => Exec['pe_apt_update'],
        }

        exec { 'pe_apt_update':
          command     => '/usr/bin/apt-get update',
          logoutput   => 'on_failure',
          refreshonly => true,
        }
      }
      /^sles-(11|12)-x86_64$/: {
        $repo_file = "/etc/zypp/repos.d/${repo_name}.repo"

        # In Puppet Enterprise, agent packages are served by the same server
        # as the master, which can be using either a self signed CA, or an external CA.
        # Zypper has issues with validating a self signed CA, so for now disable ssl verification.
        $repo_settings = {
          'name'        => $repo_name,
          'enabled'     => '1',
          'autorefresh' => '0',
          'baseurl'     => '',
          'type'        => 'rpm-md',
        }

        $repo_settings.each |String $setting, String $value| {
          pe_ini_setting { "zypper ${repo_name} ${setting}":
            ensure  => present,
            path    => $repo_file,
            section => $repo_name,
            setting => $setting,
            value   => $value,
            notify  => Exec['pe_zyp_update'],
          }
        }

        # the repo should be refreshed on any change so that new artifacts
        # will be recognized
        exec { 'pe_zyp_update':
          command     => "/usr/bin/zypper ref ${repo_name}",
          logoutput   => 'on_failure',
          refreshonly => true,
        }
      }
      default: {
        fail("Unable to cleanup package repository configuration. Platform described by facts['platform_tag'] '${facts['platform_tag']}' is not a known master platform.")
      }
    }
  }
}
