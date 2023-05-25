# @summary Base cd4pe class that configures the system for anything shared across
# all components.
#
# @param runtime which runtime is being used
class cd4pe (
  Cd4pe::Runtime $runtime,
) {
  file { '/etc/puppetlabs/cd4pe':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if($runtime == 'docker') {
    docker_network { 'cd4pe':
      ensure  => present,
    }
  }
}
