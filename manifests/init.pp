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

  warn('This version of puppetlabs-cd4pe does not install or configure CD4PE or its database.')

}
