class cd4pe::job_hardware (
  String[1] $access_token,
  Sensitive[String[1]] $secret_key,
  String $cd4pe_web_ui_endpoint    = "${cd4pe::resolvable_hostname}:${cd4pe::web_ui_port}",
  Optional[Boolean] $start_agent   = undef,
  Optional[String[1]] $version     = undef,
  Optional[String[1]] $data_dir    = undef,
  Optional[String[1]] $install_dir = undef,
) {
    class { 'pipelines::agent': 
      access_token => Sensitive($access_token),
      secret_key   => $secret_key,
      download_url => "${cd4pe_web_ui_endpoint}/download/client",
      start_agent  => $start_agent,
      data_dir     => $data_dir,
      install_dir  => $install_dir,
      version      => $version
    }
}

