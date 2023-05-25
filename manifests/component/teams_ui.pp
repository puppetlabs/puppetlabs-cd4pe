# @summary installs and configures the teams_ui service component.
#
# @param config subset of Cd4pe::Config specific to the teams_ui service.
class cd4pe::component::teams_ui (
  Cd4pe::Config::Teams_ui $config
) {
  include cd4pe::log_rotation

  $nginx_conf_path = '/etc/puppetlabs/cd4pe/base.conf.template'
  file { $nginx_conf_path:
    ensure => 'file',
    source => 'puppet:///modules/cd4pe/nginx/base.conf.template',
    owner  => 'root',
    group  => 'root',
  }

  if $config['runtime'] == 'docker' {
    $container = $config['container']
    docker_volume { $container['log_volume_name']:
      ensure => present,
    }

    docker::run { $container['name']:
      image            => $container['image'],
      net              => 'cd4pe',
      extra_parameters => $container['extra_parameters'],
      ports            => ['443:3000'],
      pull_on_start    => false,
      volumes          => [
        "${container['log_volume_name']}:/app/logs",
        "${nginx_conf_path}:/etc/nginx/templates/base.conf.template",
        '/etc/puppetlabs/cd4pe/browser_certs:/etc/nginx/certs',
      ],
      env              => [
        'CD4PE_SERVICE=http://pipelinesinfra:8080',
        'QUERY_SERVICE=http://query:8888',
        "LOGGING=${config['console_log_level']}",
        "TEAMS_UI_VERSION=${config['teams_ui_version']}"
      ],
    }

    cd4pe::logrotate_config { 'ui':
      path            => "/var/lib/docker/volumes/${container['log_volume_name']}/_data/*.log",
      size_mb         => $config['max_log_size_mb'],
      # SIGUSR1 re-opens the log file. See https://docs.nginx.com/nginx/admin-guide/basic-functionality/runtime-control/
      post_rotate_cmd => "docker kill ${container['name']} -s SIGUSR1",
      keep_files      => $config['keep_log_files'],
    }
  }
}
