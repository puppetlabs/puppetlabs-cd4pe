# Slots the catalog_diff_api extension JAR into a Puppet Server install. Use
# this class by adding it to the "PE Masters" group or otherwise applying it to
# a node running PE or Open Source Puppet Server.
class catalog_diff_api::server (
  Enum['present', 'absent'] $ensure = 'present',
  Array[String] $whitelisted_certnames = [$trusted['certname']],
) {
  if fact('pe_server_version') =~ String {
    # PE configuration
    if (versioncmp(fact('pe_server_version'), '2018.1.0') < 0) or
       (versioncmp(fact('pe_server_version'), '2018.2.0') >= 0) {
      warning("The puppetserver_diff_api::server class only supports PE 2018.1 and should be removed from: ${trusted['certname']}")
      $_ensure = absent
    } else {
      $_ensure = $ensure
    }

    if $_ensure == 'present' {
      # PE needs a services.d directory added to the bootstrap path that can be
      # used to slot in additional services.
      Pe_ini_setting <| title == 'puppetserver initconf bootstrap_config' |> {
        value => '/etc/puppetlabs/puppetserver/bootstrap.cfg,/etc/puppetlabs/puppetserver/services.d/'
      }

      # NOTE: An exec is used here instead of a file resource to avoid a
      # potential duplicate resource issue if this sort of extension module
      # gets repeated for a different use case.
      exec {'ensure puppetserver services.d directory existance':
        command => 'mkdir -m 0755 -p /etc/puppetlabs/puppetserver/services.d',
        creates => '/etc/puppetlabs/puppetserver/services.d',
        umask   => '0022',
        path    => '/bin:/usr/bin',
        user    => 'root',
      }

      $_service_file_deps = [Exec['ensure puppetserver services.d directory existance']]
    } else {
      $_service_file_deps = []
    }

    $_puppetserver_service = Exec['pe-puppetserver service full restart']
  } else {
    # FOSS configuration

    # FIXME: Fail if Puppet Server 5.3 isn't in use.
    $_ensure = $ensure
    $_puppetserver_service = Service['puppetserver']
    $_service_file_deps = []
  }

  $_file_ensure = $_ensure ? {
    'present' => file,
    'absent'  => absent,
  }

  file {'/etc/puppetlabs/puppetserver/services.d/catalog_diff_api.cfg':
    ensure  => $_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "puppetlabs.services.catalog-diff-api.catalog-diff-api-service/catalog-diff-api-service\n",
    require => $_service_file_deps,
    notify  => $_puppetserver_service,
  }

  file {'/opt/puppetlabs/server/data/puppetserver/jars/catalog-diff-api.jar':
    ensure => $_file_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/catalog_diff_api/catalog-diff-api.jar',
    backup => false,
    notify => $_puppetserver_service,
  }

  puppet_authorization::rule {'catalog diff API access':
    ensure               => $_ensure,
    match_request_path   => '/puppet/v3/diff-catalog',
    match_request_type   => 'path',
    match_request_method => 'get',
    allow                => $whitelisted_certnames,
    sort_order           => 601,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => $_puppetserver_service,
  }
}
