# DO NOT INCLUDE OR DECLARE THIS CLASS. This class is private and intended to
# be declared by puppet_enterprise::repo.
#
# DESCRIPTION
# Private class for configuring yum, apt and zypper repos to point to the
# pe_repo hosted packages on the Master of Master.
#
# TWO-CLASS STAGES PATTERN
# This class is the private half of a two-class stages pattern. See the
# puppet_enterprise::repo class for more information.
class cd4pe::repo::config(
  String  $master = $servername,
  Boolean $manage = true,
) {

  # Variables for configuring the repos to be able to communicate
  # with the puppetserver using puppets PKI
  $ssl_dir = '/etc/puppetlabs/puppet/ssl'
  $sslcacert_path = "${ssl_dir}/certs/ca.pem"
  $sslclientcert_path = "${ssl_dir}/certs/${facts['clientcert']}.pem"
  $sslclientkey_path = "${ssl_dir}/private_keys/${facts['clientcert']}.pem"

  # On primary, the repo should point to the local directory
  $base_source = "https://${master}:8140/packages"

  $pe_ver = pe_empty($facts['pe_build']) ? { false => $facts['pe_build'], true => pe_build_version() }

  $source = "${base_source}/${pe_ver}/puppet_enterprise"

  $gpg_keys = [
    "${base_source}/GPG-KEY-puppetlabs",
    "${base_source}/GPG-KEY-puppet",
  ]

  if $manage == true {

    $repo_name = 'cd4pe'

    case $facts['platform_tag'] {
      /^(el|redhatfips)-[67]-x86_64$/: {
        #Remove legacy repo files
        file { '/etc/yum.repos.d/pe_repo.repo':
          ensure => absent,
        }
        file { '/etc/yum.repos.d/pc_repo.repo':
          ensure => absent,
        }

        yumrepo { $repo_name:
          ensure        => present,
          baseurl       => $source,
          descr         => 'Puppet Labs PE Packages $releasever - $basearch', # don't want to interoplate those - they are yum strings
          enabled       => true,
          gpgcheck      => '1',
          gpgkey        => pe_join($gpg_keys, "\n\t"),
          sslcacert     => $sslcacert_path,
          sslclientcert => $sslclientcert_path,
          sslclientkey  => $sslclientkey_path,
        }
      }
      /^ubuntu-(12|14|16|18)\.04-amd64$/: {
        $conf_settings = [
          "Acquire::https::${master}::Verify-Peer false;",
          "Acquire::http::Proxy::${master} DIRECT;"
        ]

        # File resource defaults from the master class are getting applied here due to PUP-3692,
        # need to be explicit with owner/group, otherwise they get set to pe-puppet.
        file { "/etc/apt/apt.conf.d/90${repo_name}":
          ensure  => file,
          owner   => '0',
          group   => '0',
          content => pe_join($conf_settings, "\n"),
          notify  => Exec['pe_apt_update'],
        }

        file { "/etc/apt/sources.list.d/${repo_name}.list":
          ensure  => file,
          owner   => '0',
          group   => '0',
          content => "deb ${source} ./",
          notify  => Exec['pe_apt_update'],
        }

        exec { 'pe_apt_update':
          command     => '/usr/bin/apt-get update',
          logoutput   => 'on_failure',
          refreshonly => true,
        }
      }
      /^sles-(11|12)-x86_64$/: {
        $repo_file = "/etc/zypp/repos.d/${repo_name}.repo"

        # In Puppet Enterprise, agent packages are served by the same server
        # as the master, which can be using either a self signed CA, or an external CA.
        # Zypper has issues with validating a self signed CA, so for now disable ssl verification.
        $repo_settings = {
          'name'        => $repo_name,
          'enabled'     => '1',
          'autorefresh' => '0',
          'baseurl'     => "${source}?ssl_verify=no",
          'type'        => 'rpm-md',
        }

        $repo_settings.each |String $setting, String $value| {
          pe_ini_setting { "zypper ${repo_name} ${setting}":
            ensure  => present,
            path    => $repo_file,
            section => $repo_name,
            setting => $setting,
            value   => $value,
            notify  => Exec['pe_zyp_update'],
          }
        }

        # the repo should be refreshed on any change so that new artifacts
        # will be recognized
        exec { 'pe_zyp_update':
          command     => "/usr/bin/zypper ref ${repo_name}",
          logoutput   => 'on_failure',
          refreshonly => true,
        }
      }
      default: {
        fail("Unable to generate package repository configuration. Platform described by facts['platform_tag'] '${facts['platform_tag']}' is not a known master platform.")
      }
    }
  }
}
