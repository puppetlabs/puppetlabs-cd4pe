# @summary installs and configures the main backend component
#
# @param config subset of Cd4pe::Config specific to pipelinesinfra
class cd4pe::component::pipelinesinfra (
  Cd4pe::Config::Pipelinesinfra $config,
) {
  include 'cd4pe::interservice_auth'

  $log_target_path = '/app/logs'
  $log4j_src_path = '/etc/puppetlabs/cd4pe/log4j2.properties'
  $log4j_target_path = '/opt/pfi/log4j2.properties'

  # Needed for backup and restore
  package { 'zip':
    ensure => present,
  }

  file { $config['secret_key_path']:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => Sensitive("PFI_SECRET_KEY=${config['secret_key'].unwrap}\n"),
    replace => false,
  }

  $container = $config['container']

  $app_data = {
    'analytics'       => $config['analytics'],
    'root_username'   => $config['root_username'],
    # Hardcode password to puppetlabs instead of reading from config
    # Need to solve bcrypt from puppet, or change backend - CDPE-5616
    'root_password'   => '$2a$10$K8MdeGgOd5OpH0JL5BZLY.YogqNcpopZZIhxfI0lI0LX4E0Ij0n2m',
    'web_ui_endpoint' => "https://${config['resolvable_hostname']}",
    'jvm_args'        => '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4000 -Duser.timezone=UTC -Xmx512M -Xms512M',
    'log4j_path'      => $log4j_target_path,
    'env_vars'        => $config['env_vars'],
  }

  file { '/etc/puppetlabs/cd4pe/env':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/cd4pe_env.epp', $app_data),
    notify    => Docker::Run[$container['name']],
  }

  file { [
      '/var/lib/puppetlabs',
      '/var/lib/puppetlabs/cd4pe',
      $config['backup_dir'],
    ]:
      ensure    => directory,
      owner     => 'root',
      group     => 'root',
      show_diff => false,
  }

  file { '/etc/puppetlabs/cd4pe/pfi-config.json':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/pfi-config.json.epp',
    {
      'db_username' => $config['db_username'],
      'db_password' => $config['db_password'].unwrap,
    }),
    notify    => Docker::Run[$container['name']],
  }

  $log4j_config = {
    'log_dir'       => $log_target_path,
    'log_file_size' => "${config['max_log_size_mb']}MB",
    'log_level'     => $config['log_level'],
    'keep_files'    => $config['keep_log_files'],
  }

  file { $log4j_src_path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/log4j2.properties.epp', $log4j_config),
  }

  docker_volume { 'cd4pe-disk-storage':
    ensure => present,
  }

  docker_volume { $container['log_volume_name']:
    ensure => present,
  }

  docker::run { $container['name']:
    image            => $container['image'],
    net              => 'cd4pe',
    extra_parameters => $container['extra_parameters'],
    ports            => [
      '8080:8080',
      '8000:8000',
    ],
    volumes          => [
      'cd4pe-disk-storage:/disk',
      'cd4pe-query-service-token:/etc/puppetlabs/cd4pe',
      "${container['log_volume_name']}:${log_target_path}",
      '/etc/puppetlabs/cd4pe/pfi-config.json:/etc/cd4pe/pfi-config.json',
      "${log4j_src_path}:${log4j_target_path}"
    ],
    pull_on_start    => false,
    env_file         => [
      '/etc/puppetlabs/cd4pe/env',
      '/etc/puppetlabs/cd4pe/secret_key',
    ],
    require          => Class['cd4pe::interservice_auth'],
  }
}
