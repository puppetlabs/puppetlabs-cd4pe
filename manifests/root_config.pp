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
  include cd4pe::anchors

  # If SSL is enabled, trigger a refresh of the CD4PE service on config update.
  # If SSL is not enabled, there's no need.
  $notify = $ssl_enabled ? {
    true    => Anchor['cd4pe-service-refresh'],
    default => undef,
  }

  cd4pe_root_config { $web_ui_endpoint:
    root_email                => $root_email,
    root_password             => $root_password,
    web_ui_endpoint           => $web_ui_endpoint,
    backend_service_endpoint  => $backend_service_endpoint,
    agent_service_endpoint    => $agent_service_endpoint,
    storage_provider          => $storage_provider,
    storage_endpoint          => $storage_endpoint,
    storage_bucket            => $storage_bucket,
    storage_prefix            => $storage_prefix,
    s3_access_key             => $s3_access_key,
    s3_secret_key             => $s3_secret_key,
    artifactory_access_token  => $artifactory_access_token,
    ssl_enabled               => $ssl_enabled,
    ssl_server_certificate    => $ssl_server_certificate,
    ssl_authority_certificate => $ssl_authority_certificate,
    ssl_server_private_key    => $ssl_server_private_key,
    ssl_endpoint              => $ssl_endpoint,
    ssl_port                  => $ssl_port,
    require                   => Anchor['cd4pe-service-install'],
    notify                    => $notify,
  }

  if ($install_shared_job_hardware) {
    warn("The Distelli agent has been deprecated in favor of using the Puppet agent for job hardware. Please migrate job hardware servers to use the Puppet agent: https://puppet.com/docs/continuous-delivery/latest/agent_migration.html")
    $job_hardware_installed = cd4pe::has_job_hardware($web_ui_endpoint, $root_email, $root_password)
    if(!$job_hardware_installed) {
      $creds_hash = cd4pe::get_agent_credentials($web_ui_endpoint, $root_email, $root_password)

      if($creds_hash) {
        exec { 'wait for CD4PE':
          require => Cd4pe_root_config[$web_ui_endpoint],
          before => Class["pipelines::agent"],
          command => "sleep 1",
          path => "/usr/bin:/bin"
        }

        class { 'pipelines::agent':
          access_token => Sensitive($creds_hash[access_token]),
          secret_key   => Sensitive($creds_hash[secret_key]),
          download_url => "${web_ui_endpoint}/download/client",
          start_agent  => $job_hardware_start_agent,
          data_dir     => $job_hardware_data_dir,
          install_dir  => $job_hardware_install_dir,
          version      => $job_hardware_agent_version,
        }
      }
    }
  }
}
