class cd4pe::impact_analysis (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Array[String]] $allowed_certnames = undef,
) {
  # If earlier than 2017.3, notify the customer this has no effect
  if (versioncmp(pe_build_version(), '2017.3.0') < 0) {
    warning("The cd4pe::impact_analysis class only supports PE 2017.3 through 2019.1 and should be removed from: ${trusted['certname']}")
  } elsif (versioncmp(pe_build_version(), '2019.1.0') < 0) {
    # If between 2017.3 and 2019.1, use the legacy
    class { 'cd4pe::impact_analysis::legacy':
      ensure            => $ensure,
      allowed_certnames => $allowed_certnames
    }
  } else {
    # If > 2019.1, we have our new catalog endpoint built in, no need for our legacy code
    class { 'cd4pe::impact_analysis::legacy':
      ensure => absent,
    }

    Pe_puppet_authorization::Rule <| title == 'puppetlabs environment' |> {
      allow +> { 'rbac' => { 'permission' => 'puppetserver:compile_catalog:*' }}
    }

    Pe_puppet_authorization::Rule <| title == 'puppetlabs v4 catalog' |> {
      allow +> { 'rbac' => { 'permission' => 'puppetserver:compile_catalog:*' }}
    }


    # if > 2019.2, enable hiera tracing
    if(versioncmp(pe_build_version(), '2019.2.0') >= 0) {
      hocon_setting { 'enable lookup tracing':
        ensure  => present,
        path    => '/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf',
        setting => 'jruby-puppet.track-lookups',
        value   => true,
        notify  => Service['pe-puppetserver']
      }
    }
  }
}
