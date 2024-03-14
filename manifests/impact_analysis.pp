# class cd4pe::impact_analysis
# @param ensure Enum type with default of present to implement legacy impact analysis
# @param allowed_certnames Optional Array of Strings that allows for certnames to passed to legacy impact analysis
class cd4pe::impact_analysis (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Array[String]] $allowed_certnames = undef,
) {
  # If earlier than 2021.1.0, notify the customer this has no effect
  if (versioncmp(pe_build_version(), '2021.1') < 0) {
    warning("The cd4pe::impact_analysis class only supports PE 2021 and newer. It should be removed from: ${trusted['certname']}")
  } else {
    Pe_puppet_authorization::Rule <| title == 'puppetlabs environment' |> {
      allow +> { 'rbac' => { 'permission' => 'puppetserver:compile_catalog:*' } }
    }

    Pe_puppet_authorization::Rule <| title == 'puppetlabs v4 catalog' |> {
      allow +> { 'rbac' => { 'permission' => 'puppetserver:compile_catalog:*' } }
    }

    hocon_setting { 'enable lookup tracing':
      ensure  => present,
      path    => '/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf',
      setting => 'jruby-puppet.track-lookups',
      value   => true,
      notify  => Service['pe-puppetserver'],
    }
  }
}
