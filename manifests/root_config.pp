class cd4pe::root_config(
  String[1] $root_email,
  Sensitive[String[1]] $root_password,
  String[1] $resolvable_hostname                           = $cd4pe::resolvable_hostname,
  String[1] $agent_service_endpoint                        = "${resolvable_hostname}:${cd4pe::agent_service_port}",
  String[1] $backend_service_endpoint                      = "${resolvable_hostname}:${cd4pe::backend_service_port}",
  String[1] $web_ui_endpoint                               = "${resolvable_hostname}:${cd4pe::web_ui_port}",
  Enum['DISK', 'ARTIFACTORY', 'S3'] $storage_provider      = 'DISK',
  String[1] $storage_bucket                                = 'cd4pe',
  Optional[String[1]] $storage_endpoint                    = undef,
  Optional[String[1]] $storage_prefix                      = undef,
  Optional[String[1]] $s3_access_key                       = undef,
  Optional[Sensitive[String[1]]] $s3_secret_key            = undef,
  Optional[Sensitive[String[1]]] $artifactory_access_token = undef,
  Optional[Boolean] $ssl_enabled                           = undef,
  Optional[String[1]] $ssl_server_certificate              = undef,
  Optional[String[1]] $ssl_authority_certificate           = undef,
  Optional[Sensitive[String[1]]] $ssl_server_private_key   = undef,
  Optional[String[1]] $ssl_endpoint                        = undef,
  Optional[Integer] $ssl_port                              = 8443,
  Optional[Boolean] $install_shared_job_hardware           = false,
  Optional[Boolean] $job_hardware_start_agent              = true,
  Optional[String] $job_hardware_data_dir                  = '/home/distelli/data',
  Optional[String] $job_hardware_install_dir               = '/home/distelli/bin',
  Optional[String] $job_hardware_agent_version             = undef,
) inherits cd4pe {

  warning('Beginning with version 3.0.0 of this module, we no longer support the installation of CD4PE or management of databases.')

  file{[$job_hardware_data_dir, $job_hardware_install_dir]:
    ensure => absent,
  }
}
