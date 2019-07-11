class cd4pe::db(
  String[1] $data_root_dir,
  Optional[String[1]] $db_host                    = undef,
  Optional[String[1]] $db_name                    = undef,
  Optional[Sensitive[String[1]]] $db_pass         = undef,
  Optional[Integer] $db_port                      = undef,
  Optional[String[1]] $db_prefix                  = undef,
  Optional[String[1]] $db_user                    = undef,
  Optional[Enum['mysql','postgres']] $db_provider = undef,
  Boolean $manage_database                        = true,
){

  assert_private()

  if $manage_database {
    if $db_provider == undef {
      # Check if the customer is using a mysql db from a previous install
      $cd4pe_docker_facts = fact('docker.network.cd4pe.Containers')
      if !empty($cd4pe_docker_facts) {
        $cd4pe_mysql = $cd4pe_docker_facts.filter |$k, $v| { $v['Name'] == 'cd4pe_mysql' }.values
        if !empty($cd4pe_mysql) {
          $_db_provider = 'mysql'
        } else {
          $_db_provider = 'postgres'
        }
      } else {
        $_db_provider = 'postgres'
      }
    } else {
      $_db_provider = $db_provider
    }


    if $_db_provider == 'mysql' {
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
    $app_db_password_path = "${data_root_dir}/cd4pe_db_password"
    $_db_pass = unwrap($db_pass)
    file { $app_db_password_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => "DB_PASS=${_db_pass}\n",
      replace => false,
    }

    Docker::Run <| title == 'cd4pe' |> {
      env_file +> ["${cd4pe::db::data_root_dir}/cd4pe_db_password"]
    }

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
      content => "DB_PASS=${_db_pass}\n",
      replace => false,
    }

    Docker::Run <| title == 'cd4pe' |> {
      env_file +> ["${cd4pe::db::data_root_dir}/cd4pe_db_password"]
    }
  }
}
