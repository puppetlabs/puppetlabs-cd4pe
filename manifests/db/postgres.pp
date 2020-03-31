class cd4pe::db::postgres(
  String $db_host                         = $trusted['certname'],
  String $db_name                         = 'cd4pe',
  Integer $db_port                        = 5432,
  String $db_prefix                       = '',
  String $db_user                         = 'cd4pe',
  String $listen_address                  = '*',
  String $ip_mask_allow_all_users         = '0.0.0.0/0',
  String $ip_mask_allow_all_users_ssl     = '0.0.0.0/0',
  String $ipv6_mask_allow_all_users_ssl   = '::/0',
  Array[String] $ssl_ciphers              = [ 'ECDHE-ECDSA-AES256-GCM-SHA384', 'ECDHE-RSA-AES256-GCM-SHA384', 'ECDHE-ECDSA-CHACHA20-POLY1305',
                                              'ECDHE-RSA-CHACHA20-POLY1305', 'ECDHE-ECDSA-AES128-GCM-SHA256', 'ECDHE-RSA-AES128-GCM-SHA256',
                                              'ECDHE-ECDSA-AES256-SHA384', 'ECDHE-RSA-AES256-SHA384', 'ECDHE-ECDSA-AES128-SHA256', 'ECDHE-RSA-AES128-SHA256' ],
) {


  if( fact('cd4pe_multimodule_packaging') =~ Undef ) {
    # This is being compiled via classification, so we can include
    # the packages class and auto-determine the versioning
    include cd4pe::repo
    if(versioncmp(pe_compiling_server_version(), '2019.1.0') >= 0) {
      $multimodule_packaging = true
    } else {
      $multimodule_packaging = false
    }
  } else {
    # this is a local puppet apply, which should be from our one click install
    $multimodule_packaging = fact('cd4pe_multimodule_packaging')
    if($multimodule_packaging == undef) {
      fail('fact cd4pe_multimodule_packaging must be set if running via puppet apply')
    }
  }

  if(any2bool($multimodule_packaging)) {
    $client_package_name = 'pe-postgresql96'
    $contrib_package_name = 'pe-postgresql96-contrib'
    $server_package_name = 'pe-postgresql96-server'
    $default_database = 'postgres'
  } else {
    $client_package_name = 'pe-postgresql'
    $contrib_package_name = 'pe-postgresql-contrib'
    $server_package_name = 'pe-postgresql-server'
    $default_database = 'pe-postgres'
  }

  $certname = $trusted['certname']
  $pg_version  = '9.6'
  $pg_bin_dir  = '/opt/puppetlabs/server/bin'
  $pg_sql_path = '/opt/puppetlabs/server/bin/psql'
  $pgsqldir    = '/opt/puppetlabs/server/data/postgresql'
  $pgsql_data_dir = "${pgsqldir}/${pg_version}/data"
  $pg_ident_conf_path = "${pgsql_data_dir}/pg_ident.conf"
  $postgres_cert_dir = "${pgsql_data_dir}/certs"
  $pg_user = 'pe-postgres'
  $pg_group = 'pe-postgres'

  $ssl_dir = "/etc/puppetlabs/puppet/ssl"
  $client_pem_key = "${ssl_dir}/private_keys/${certname}.pem"
  $client_cert    = "${ssl_dir}/certs/${certname}.pem"
  $client_ca_cert    = "${ssl_dir}/certs/ca.pem"

  class { 'pe_postgresql::globals':
    user                 => $pg_user,
    group                => $pg_group,
    client_package_name  => $client_package_name,
    contrib_package_name => $contrib_package_name,
    server_package_name  => $server_package_name,
    service_name         => 'pe-postgresql',
    default_database     => $default_database,
    version              => $pg_version,
    bindir               => $pg_bin_dir,
    datadir              => $pgsql_data_dir,
    confdir              => $pgsql_data_dir,
    psql_path            => $pg_sql_path,
    needs_initdb         => true,
    pg_hba_conf_defaults => false,
  }

  File {
    ensure  => file,
    owner   => $pg_user,
    group   => $pg_group,
    mode    => '0400',
  }

  # manage the directories the pgsql server will use
  file {[$pgsqldir, "${pgsqldir}/${pg_version}" ]:
    ensure  => directory,
    mode    => '0755',
    owner   => $pg_user,
    group   => $pg_group,
    require => Class['pe_postgresql::server::install'],
    before  => Class['pe_postgresql::server::initdb'],
  }

  # Ensure /etc/sysconfig/pgsql exists so the module can create and manage
  # pgsql/postgresql on el-7
  if ($facts['os']['family'] == 'RedHat') and ($facts['os']['release']['major'] !~ '^7') {
    file { '/etc/sysconfig/pgsql':
      ensure  => directory,
      require => File[$pgsqldir, "${pgsqldir}/${pg_version}" ],
    }
  }

  # get the pg server up and running
  class { 'pe_postgresql::server':
    listen_addresses        => $listen_address,
    ip_mask_allow_all_users => $ip_mask_allow_all_users,
    package_ensure          => 'latest',
  }

  # The contrib package provides pg_upgrade, which is necessary for migrations
  # form one version of postgres (9.4 -> 9.6, for example)
  class { 'pe_postgresql::server::contrib':
    package_ensure => 'latest',
  }

  # The client package is a dependency of pe-postgresql-server, but upgrading
  # pe-postgresql-server to latest does not in all cases ensure that pe-postgresql
  # is upgrading to the same version. This resource makes it explicit.
  class { 'pe_postgresql::client':
    package_ensure => 'latest',
  }

  pe_postgresql::server::database { 'postgres':
      owner   => 'pe-postgres',
      require => Class['pe_postgresql::server']
  }

  pe_postgresql::server::database { 'pe-postgres':
      owner   => 'pe-postgres',
      require => Class['pe_postgresql::server']
  }

  pe_postgresql::server::tablespace { $db_name:
    location => "${pgsqldir}/${pg_version}/${db_name}",
    require  => Class['pe_postgresql::server'],
  }

  # create our database
  pe_postgresql::server::db { $db_name:
    user       => 'cd4pe',
    password   => undef,
    tablespace => $db_name,
    require    => Pe_postgresql::Server::Tablespace[$db_name],
  }

  pe_concat { $pg_ident_conf_path:
    owner          => $pg_user,
    group          => $pg_group,
    force          => true, # do not crash if there is no pg_ident_rules
    mode           => '0640',
    warn           => true,
    require        => [Package['postgresql-server'], Class['pe_postgresql::server::initdb']],
    notify         => Class['pe_postgresql::server::reload'],
    ensure_newline => true,
  }

  pe_postgresql::server::pg_hba_rule { 'local access as pe-postgres user':
    database    => 'all',
    user        => 'pe-postgres',
    type        => 'local',
    auth_method => 'peer',
    order       => '001',
  }

  class { 'cd4pe::db::postgres::certs':
    pg_user            => $pg_user,
    pg_group           => $pg_group,
    pg_cert_dir        => $postgres_cert_dir,
    client_ca_cert     => $client_ca_cert,
    client_cert        => $client_cert,
    client_private_key => $client_pem_key,
    require            => File[$pgsqldir]
  }

  cd4pe::db::app_db_env { 'app_db_env file':
    db_host     => $db_host,
    db_port     => $db_port,
    db_prefix   => $db_prefix,
    db_provider => 'postgres',
    db_name     => $db_name,
    db_user     => $db_user,
  }

  pe_postgresql::server::config_entry { 'ssl' :
    value => 'on',
  }

  pe_postgresql::server::config_entry { 'ssl_ciphers':
    value => pe_join($ssl_ciphers, ':'),
  }

  pe_postgresql::server::config_entry { 'ssl_ca_file' :
    value => $client_ca_cert,
  }
  pe_postgresql::server::config_entry { 'ssl_cert_file' :
    value => "${postgres_cert_dir}/${certname}.cert.pem",
  }
  pe_postgresql::server::config_entry { 'ssl_key_file' :
    value => "${postgres_cert_dir}/${certname}.private_key.pem",
  }

  puppet_enterprise::pg::cert_whitelist_entry { 'cd4pe_whitelist':
    user                          => $db_user,
    database                      => $db_name,
    allowed_client_certname       => $certname,
    pg_ident_conf_path            => $pg_ident_conf_path,
    ip_mask_allow_all_users_ssl   => $ip_mask_allow_all_users_ssl,
    ipv6_mask_allow_all_users_ssl => $ipv6_mask_allow_all_users_ssl,
  }
}
