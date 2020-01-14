#
# @param object_store_path The path that should be mounted at /disk in the
#   container. By default this is the docker volume "object_store_path"
#  buf if set an absolut path this will allow for mounting local directories.
#
class cd4pe (
  Integer $agent_service_port                    = 7000,
  Boolean $analytics                             = true,
  Integer $backend_service_port                  = 8000,
  Array[String] $cd4pe_docker_extra_params       = [],
  String $object_store_path                      = 'cd4pe-object-store',
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
  Optional[String[1]] $cd4pe_network_subnet      = undef,
  Optional[String[1]] $cd4pe_network_gateway     = undef,
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
    content => Sensitive("PFI_SECRET_KEY=${secret_key}\n"),
    replace => false,
  }

  # DEPRECATED: 'dynamodb' and 'mysql' db_providers
  # As part of our effort to streamline the installation process and ensure Continuous Delivery for PE meets
  # performance standards, support for MySQL and Amazon DynamoDB external databases is deprecated in
  # Continuous Delivery for PE version 3.1.0, and will be removed in a future release. 
  # Before support ends, we'll provide information about how to migrate your external database to a supported option.
  #
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

  if $effective_db_provider == 'mysql'  {
    $net = 'cd4pe'
    docker_network {$net:
      ensure  => present,
      subnet  => $cd4pe_network_subnet,
      gateway => $cd4pe_network_gateway,
    }
  } else {
    $net = 'bridge'
  }

  class { 'cd4pe::db':
    data_root_dir         => $data_root_dir,
    db_host               => $db_host,
    db_name               => $db_name,
    db_pass               => $db_pass,
    db_port               => $db_port,
    db_prefix             => $db_prefix,
    db_user               => $db_user,
    db_provider           => $db_provider,
    effective_db_provider => $effective_db_provider,
    manage_database       => $manage_database,
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
    $extra_params = [
      "--add-host ${master_server}:${master_ip}",
      "--add-host ${trusted['certname']}:${facts['ipaddress']}"
      ] + $cd4pe_docker_extra_params
  } else {
    $extra_params = $cd4pe_docker_extra_params
  }

  $container_require = $manage_database ? {
    true => [Docker::Run[$db_host], File[$secret_key_path]],
    false => [File[$secret_key_path]],
  }

  # If we are running docker on a machine that has SELinux enforcing, we need
  # to tell docker to relabel the mounts to use the correct SELinux contexts.
  # This is what the :K flag is for
  $volume_mount_suffix = $facts['os'].dig('selinux', 'enabled') ? {
    true    => ':Z',
    default => '',
  }

  docker::run {'cd4pe':
    image            => "${cd4pe_image}:${cd4pe_version}",
    extra_parameters => $extra_params,
    ports            => $cd4pe_ports,
    pull_on_start    => true,
    volumes          => ["${object_store_path}:/disk${volume_mount_suffix}"],
    net              => $net,
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
