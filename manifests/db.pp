class cd4pe::db(
  String[1] $data_root_dir,
  Optional[String[1]] $db_host                              = undef,
  Optional[String[1]] $db_name                              = undef,
  Optional[Sensitive[String[1]]] $db_pass                   = undef,
  Optional[Integer] $db_port                                = undef,
  Optional[String[1]] $db_prefix                            = undef,
  Optional[String[1]] $db_user                              = undef,
  Optional[Enum['mysql','postgres']] $db_provider           = undef,
  Optional[Enum['mysql','postgres']] $effective_db_provider = undef,
  Boolean $manage_database                                  = true,
){

  assert_private()

  # DEPRECATED: 'mysql' db_provider
  # As part of our effort to streamline the installation process and ensure Continuous Delivery for PE meets
  # performance standards, support for MySQL and Amazon DynamoDB external databases is deprecated in
  # Continuous Delivery for PE version 3.1.0, and will be removed in a future release. 
  # Before support ends, we'll provide information about how to migrate your external database to a supported option.
  #
  if $manage_database {
    if $effective_db_provider == 'mysql' {
      class { 'cd4pe::db::mysql':
        db_host   => $db_host,
        db_name   => $db_name,
        db_pass   => $db_pass,
        db_port   => $db_port,
        db_prefix => $db_prefix,
        db_user   => $db_user,
      }
    } else {
      # Fresh install, default to postgres
      class { 'cd4pe::db::postgres':
        db_host   => $db_host,
        db_name   => $db_name,
        db_port   => $db_port,
        db_prefix => $db_prefix,
        db_user   => $db_user,
      }
    }
  } else {
    cd4pe::db::app_db_env { 'app_db_env file':
      db_host     => $db_host,
      db_port     => $db_port,
      db_prefix   => $db_prefix,
      db_provider => $db_provider,
      db_name     => $db_name,
      db_user     => $db_user,
    }

    $app_db_password_path = "${data_root_dir}/cd4pe_db_password"
    $_db_pass = unwrap($db_pass)
    file { $app_db_password_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => Sensitive.new("DB_PASS=${_db_pass}\n"),
      replace => false,
    }

    Docker::Run <| title == 'cd4pe' |> {
      env_file +> ["${cd4pe::db::data_root_dir}/cd4pe_db_password"]
    }
  }
}
