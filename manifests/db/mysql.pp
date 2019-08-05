class cd4pe::db::mysql(
  String $db_host                                = 'cd4pe_mysql',
  String $db_name                                = 'cd4pe',
  Optional[Sensitive[String[1]]] $db_pass        = undef,
  Integer $db_port                               = 3306,
  String $db_prefix                              = '',
  String $db_user                                = 'cd4pe',
) {
  include docker


  if $db_pass == undef {
    $_db_pass  = cd4pe::gen_mysql_password()
  }
  else {
    $_db_pass = unwrap($db_pass)
  }

  $app_db_password_path = "${cd4pe::db::data_root_dir}/cd4pe_db_password"
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

  cd4pe::db::app_db_env { 'app_db_env file':
    db_host     => $db_host,
    db_port     => $db_port,
    db_prefix   => $db_prefix,
    db_provider => 'mysql',
    db_name     => $db_name,
    db_user     => $db_user,
  }

  $mysql_password_path = "${cd4pe::db::data_root_dir}/mysql_password"
  file { $mysql_password_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => Sensitive.new("MYSQL_ROOT_PASSWORD=${$_db_pass}\nMYSQL_PASSWORD=${$_db_pass}\n"),
    replace => false,
  }

  $mysql_env_path = "${cd4pe::db::data_root_dir}/mysql_env"
  $db_data = {
    db_name => $db_name,
    db_user => $db_user,
  }
  file { $mysql_env_path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/mysql_env.epp', $db_data),
  }

  docker::run { $db_host:
    image                 => 'mysql:5.7',
    net                   => 'cd4pe',
    ports                 => ["${db_port}:${db_port}"],
    volumes               => ['cd4pe-mysql:/var/lib/mysql'],
    env_file              => [
      $mysql_env_path,
      $mysql_password_path,
    ],
    health_check_interval => 10,
    subscribe             => File[$mysql_env_path],
  }
}
