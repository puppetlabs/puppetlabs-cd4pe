class cd4pe (
  Integer $agent_service_port                    = 7000,
  Boolean $analytics                             = true,
  Integer $backend_service_port                  = 8000,
  Array[String] $cd4pe_docker_extra_params       = [],
  String $cd4pe_image                            = 'puppet/continuous-delivery-for-puppet-enterprise',
  Variant[Enum['latest'], String] $cd4pe_version = 'latest',
  String $db_host                                = 'cd4pe_mysql',
  String $db_name                                = 'cd4pe',
  Optional[Sensitive[String[1]]] $db_pass        = undef,
  Integer $db_port                               = 3306,
  String $db_prefix                              = '',
  String $db_user                                = 'cd4pe',
  Boolean $manage_database                       = true,
  String $resolvable_hostname                    = "http://${trusted['certname']}",
  Integer $web_ui_port                           = 8080,
){
  # Restrict to linux only?
  include ::docker

  $data_root_dir = '/etc/puppetlabs/cd4pe'

  file { $data_root_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $db_pass == undef {
    $_db_pass  = cd4pe::gen_mysql_password()
  }
  else {
    $_db_pass = unwrap($db_pass)
  }

  $app_db_password_path = "${data_root_dir}/cd4pe_db_password"
  file { $app_db_password_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => "DB_PASS=${$_db_pass}\n",
    replace => false,
  }

  $db_data = {
    db_name => $db_name,
    db_user => $db_user,
  }

  $app_data = {
    analytics => $analytics,
    db_host   => $db_host,
    db_port   => $db_port,
    db_prefix => $db_prefix
  } + $db_data

  $app_env_path = "${data_root_dir}/env"
  file { $app_env_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    show_diff => false,
    content => epp('cd4pe/app_env.epp', $app_data),
  }

  $secret_key = cd4pe::secret_key()
  $secret_key_path = "${data_root_dir}/secret_key"
  file { $secret_key_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => "PFI_SECRET_KEY=${secret_key}\n",
    replace => false,
  }

  docker_network {'cd4pe':
    ensure => present,
  }

  if $manage_database {
    $mysql_password_path = "${data_root_dir}/mysql_password"
    file { $mysql_password_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => "MYSQL_ROOT_PASSWORD=${$_db_pass}\nMYSQL_PASSWORD=${$_db_pass}\n",
      replace => false,
    }

    $mysql_env_path = "${data_root_dir}/mysql_env"
    file { $mysql_env_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      show_diff => false,
      content => epp('cd4pe/mysql_env.epp', $db_data),
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


  $master_server = $::settings::server
  $master_ip     = $serverip

  $cd4pe_ports = [
    "${web_ui_port}:${web_ui_port}",
    "${backend_service_port}:${backend_service_port}",
    "${agent_service_port}:${agent_service_port}",
  ]

  $extra_params = ["--add-host ${master_server}:${master_ip}"] + $cd4pe_docker_extra_params

  $container_require = $manage_database ? {
    true => [Docker::Run[$db_host], File[$secret_key_path]],
    false => [File[$secret_key_path]],
  }

  docker::run {'cd4pe':
    image                 => "${cd4pe_image}:${cd4pe_version}",
    extra_parameters      => $extra_params,
    ports                 => $cd4pe_ports,
    volumes               => ['cd4pe-object-store:/disk'],
    env_file              => [
      $app_env_path,
      $secret_key_path,
      $app_db_password_path
    ],
    net                   => 'cd4pe',
    subscribe             => [
      File[$app_env_path],
    ],
    require               => $container_require,
  }
}
