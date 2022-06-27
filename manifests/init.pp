class cd4pe (
  $web_url = $fqdn,
) {
  notify { 'NEW MODULE BRUH': }
  include docker

  file { '/etc/cd4pe':
    ensure => directory,
  }

  file { '/etc/cd4pe/env':
    ensure  => file,
    source  => 'puppet:///modules/cd4pe/env',
    require => File['/etc/cd4pe'],
  }

  file { '/etc/cd4pe/pfi-config.json':
    ensure => file,
    source => 'puppet:///modules/cd4pe/pfi-config.json',
  }

  docker_volume { 'cd4pe-db':
    ensure => present,
  }

  docker::run { 'cd4pe':
    image    => 'gcr.io/platform-services-297419/cd4pe/continuous-delivery-for-puppet-enterprise:4.15.1',
    ports    => ['8080', '8000'],
    detach   => true,
    volumes  => ['cd4pe-db:/var/lib/postgresql/data', '/etc/cd4pe:/etc/cd4pe'],
    env_file => ['/etc/cd4pe/env'],
    require  => [
      Docker_volume['cd4pe-db'],
    ],
  }
}
