# Slots the cppe_api extension JAR into a Puppet Server install. Use
# this class by adding it to the "PE Masters" group or otherwise applying it to
# a node running PE
class cd4pe::impact_analysis (
  Array[String] $whitelisted_certnames,
  Enum['present', 'absent'] $ensure = 'present',
) {

  if fact('pe_server_version') =~ String {
    # PE configuration
    if (versioncmp(fact('pe_server_version'), '2017.3.0') < 0) or
       (versioncmp(fact('pe_server_version'), '2019.1.0') >= 0) {
      warning("The cd4pe::impact_analysis class only supports PE 2017.3 through 2019.1 and should be removed from: ${trusted['certname']}")
      $_ensure = absent
    } else {
      $_ensure = $ensure
    }
  } else {
      $_ensure = $ensure
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'cdpe-api-service':
    namespace => 'puppetlabs.services.cdpe-api.cdpe-api-service',
    container => 'puppetserver',
    ensure    => $_ensure,
    require   => Package['pe-puppetserver']
  }

   $_puppetserver_service = Exec['pe-puppetserver service full restart']

   $_file_ensure = $_ensure ? {
     'present' => file,
     'absent'  => absent,
   }

  file {'/opt/puppetlabs/server/data/puppetserver/jars/cdpe-api.jar':
    ensure  => $_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/cd4pe/cdpe-api.jar',
    backup  => false,
    notify  => $_puppetserver_service,
    require => Package['pe-puppetserver']
  }

  puppet_authorization::rule {'CDPE API access':
    ensure               => $_ensure,
    match_request_path   => '/puppet/v3/cd4pe/compile',
    match_request_type   => 'path',
    match_request_method => 'get',
    allow                => $whitelisted_certnames,
    sort_order           => 601,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => $_puppetserver_service,
    require              => Package['pe-puppetserver']
  }

  Pe_puppet_authorization::Rule <| title == 'puppetlabs environment' |> {
    allow +> $whitelisted_certnames,
  }

}
