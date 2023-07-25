# @summary installs and configures the query service component
#   which is used by the estate reporting feature.
#
# @param config subset of Cd4pe::Config specific to the query service.
# @param api_container_name name of container the query service relies on for PE information
class cd4pe::component::query (
  Cd4pe::Config::Query $config,
  String $api_container_name
) {
  include cd4pe::log_rotation

  $container = $config['container']
  cd4pe::runtime::volume { $container['log_volume_name']:
    ensure  => present,
    runtime => $config['runtime'],
  }

  $env_data = {
    api_container_name => $api_container_name,
    log_level => $config['log_level'],
    db_username => $config['db_username'],
    db_password => $config['db_password'],
    db_endpoint => $config['db_endpoint'],
    env_vars => $config['env_vars'],
  }

  file { '/etc/puppetlabs/cd4pe/query_env':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    seltype   => 'container_file_t',
    show_diff => false,
    content   => epp('cd4pe/query_env.epp', $env_data),
    notify    => Cd4pe::Runtime::Run[$container['name']],
  }

  cd4pe::runtime::run { $container['name']:
    runtime          => $config['runtime'],
    image            => $container['image'],
    extra_parameters => $container['extra_parameters'],
    net              => 'cd4pe',
    pull_on_start    => false,
    env_file         => ['/etc/puppetlabs/cd4pe/query_env'],
    volumes          => [
      "${container['log_volume_name']}:/app/logs",
      'cd4pe-query-service-token:/etc/puppetlabs/cd4pe',
    ],
  }

  if $config['runtime'] == 'docker' {
    cd4pe::logrotate_config { 'query':
      path            => "/var/lib/docker/volumes/${container['log_volume_name']}/_data/*.log",
      size_mb         => $config['max_log_size_mb'],
      post_rotate_cmd => "docker kill ${container['name']} -s SIGUSR1",
      keep_files      => $config['keep_log_files'],
    }
  }
}
