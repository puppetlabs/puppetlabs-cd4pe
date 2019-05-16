class cd4pe (
  Integer $agent_service_port                    = 7000,
  Boolean $analytics                             = true,
  Integer $backend_service_port                  = 8000,
  Array[String] $cd4pe_docker_extra_params       = [],
  String $cd4pe_image                            = 'puppet/continuous-delivery-for-puppet-enterprise',
  Variant[Enum['latest'], String] $cd4pe_version = 'latest',
  Optional[String[1]] $db_host                   = undef,
  Optional[String[1]] $db_name                   = undef,
  Optional[Sensitive[String[1]]] $db_pass        = undef,
  Optional[Integer] $db_port                     = undef,
  Optional[String[1]] $db_prefix                 = undef,
  Optional[Enum['mysql','postgres']] $db_provider = undef,
  String $db_user                                = 'cd4pe',
  Boolean $manage_database                       = true,
  Boolean $manage_pe_host_mapping                = true,
  String $resolvable_hostname                    = "http://${trusted['certname']}",
  Integer $web_ui_port                           = 8080,
  Integer $web_ui_ssl_port                       = 8443,
){
  # Restrict to linux only?
  include docker
  include cd4pe::anchors

  $data_root_dir = '/etc/puppetlabs/cd4pe'

  file { $data_root_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
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

  class { 'cd4pe::db':
    data_root_dir   => $data_root_dir,
    db_host         => $db_host,
    db_name         => $db_name,
    db_pass         => $db_pass,
    db_port         => $db_port,
    db_prefix       => $db_prefix,
    db_user         => $db_user,
    db_provider     => $db_provider,
    manage_database => $manage_database,
  }

  $app_data = {
    analytics   => $analytics,
  }

  $app_env_path = "${data_root_dir}/env"
  file { $app_env_path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/app_env.epp', $app_data),
  }

  $cd4pe_ports = [
    "${web_ui_ssl_port}:8443",
    "${web_ui_port}:8080",
    "${backend_service_port}:8000",
    "${agent_service_port}:7000",
  ]

  $master_server = $::settings::server
  $master_ip     = getvar('serverip')

  if $master_ip and $manage_pe_host_mapping {
    $extra_params = ["--add-host ${master_server}:${master_ip}"] + $cd4pe_docker_extra_params
  } else {
    $extra_params = $cd4pe_docker_extra_params
  }

  $container_require = $manage_database ? {
    true => [Docker::Run[$db_host], File[$secret_key_path]],
    false => [File[$secret_key_path]],
  }

  docker::run {'cd4pe':
    image            => "${cd4pe_image}:${cd4pe_version}",
    extra_parameters => $extra_params,
    ports            => $cd4pe_ports,
    pull_on_start    => true,
    volumes          => ['cd4pe-object-store:/disk'],
    net              => 'cd4pe',
    env_file         => [
      $app_env_path,
      $secret_key_path,
      "${data_root_dir}/db_env",
    ],
    subscribe        => File[$app_env_path],
    require          => $container_require,
    before           => Anchor['cd4pe-service-install'],
  }

  # This exec is provided as a handle for root_config, which needs to refresh
  # the service AFTER it's already been ensured running. Because the
  # root_config class is optional and doesn't always exist (and when it does,
  # THIS class doesn't always exist), the actual refresh will be handled
  # through a constant anchor resource.
  exec { 'cd4pe-service-refresh':
    refreshonly => true,
    path        => '/usr/bin:/bin',
    command     => 'systemctl restart docker-cd4pe',
    subscribe   => Anchor['cd4pe-service-refresh'],
  }
}
