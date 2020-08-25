class cd4pe::impact_analysis::legacy (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Array[String]] $allowed_certnames = undef,
) {

  if ($ensure == 'present' and empty($allowed_certnames)) {
    fail('cd4pe::impact_analysis::legacy::allowed_certnames must be a non empty array')
  }


  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'cdpe-api-service':
    ensure    => $ensure,
    container => 'puppetserver',
    namespace => 'puppetlabs.services.cdpe-api.cdpe-api-service',
    require   => Package['pe-puppetserver']
  }

  $_puppetserver_service = Exec['pe-puppetserver service full restart']

  $_file_ensure = $ensure ? {
    'present' => file,
    'absent'  => absent,
  }

  if (versioncmp(pe_build_version(), '2019.0.2') >= 0) {
    $jar_source_name = 'cdpe-api-aot.jar'
  } else {
    $jar_source_name = 'cdpe-api.jar'
  }

  file {'/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar':
    ensure  => $_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/cd4pe/${jar_source_name}",
    backup  => false,
    notify  => $_puppetserver_service,
    require => Package['pe-puppetserver']
  }

  puppet_authorization::rule {'CDPE API access':
    ensure               => $ensure,
    match_request_path   => '/puppet/v3/cd4pe/compile',
    match_request_type   => 'path',
    match_request_method => 'get',
    allow                => $allowed_certnames,
    sort_order           => 601,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => $_puppetserver_service,
    require              => Package['pe-puppetserver']
  }

  if ($ensure == 'present') {
    Pe_puppet_authorization::Rule <| title == 'puppetlabs environment' |> {
      allow +> $allowed_certnames,
    }
  }
}
