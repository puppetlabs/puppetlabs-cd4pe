# @summary installs and configures postgres as the database
#
# @param config subset of Cd4pe::Config specific to postgres
class cd4pe::component::postgres (
  Cd4pe::Config::Postgres $config
) {
  include cd4pe::log_rotation

  $container = $config['container']
  $log_directory = '/opt/bitnami/postgresql/logs'

  $preinit_script = '/etc/puppetlabs/cd4pe/preinitdb.sh'
  file { $preinit_script:
    ensure  => 'file',
    content => epp('cd4pe/postgres/preinitdb.sh.epp', { 'log_directory' => $log_directory }),
    owner   => 'root',
    group   => 'root',
    seltype => 'container_file_t',
  }

  $init_script = '/etc/puppetlabs/cd4pe/initdb.sql'
  file { $init_script:
    ensure  => 'file',
    content => epp('cd4pe/postgres/initdb.sql.epp',
      {
        'cd4pe_db_username' => $config['cd4pe_db_username'],
        'cd4pe_db_password' => $config['cd4pe_db_password'].unwrap,
        'query_db_username' => $config['query_db_username'],
        'query_db_password' => $config['query_db_password'].unwrap,
      }
    ),
    owner   => 'root',
    group   => 'root',
    seltype => 'container_file_t',
  }

  $postgres_dir = '/bitnami/postgresql'
  $conf_destination = "${postgres_dir}/conf"
  $pgdata = "${postgres_dir}/data"
  $hba_file = '/etc/puppetlabs/cd4pe/pg_hba.conf'
  file { $hba_file:
    ensure  => 'file',
    source  => 'puppet:///modules/cd4pe/postgres/pg_hba.conf',
    owner   => 'root',
    group   => 'root',
    seltype => 'container_file_t',
    notify  => Cd4pe::Runtime::Run[$container['name']],
  }

  $conf_file = '/etc/puppetlabs/cd4pe/postgresql.conf'
  file { $conf_file:
    ensure  => 'file',
    content => epp('cd4pe/postgres/postgresql.conf.epp', { 'log_directory' => $log_directory, 'log_level' => $config['log_level'] }),
    owner   => 'root',
    group   => 'root',
    seltype => 'container_file_t',
    notify  => Cd4pe::Runtime::Run[$container['name']],
  }

  cd4pe::runtime::volume { 'postgres':
    ensure  => 'present',
    runtime => $config['runtime'],
  }
  cd4pe::runtime::volume { $container['log_volume_name']:
    ensure  => 'present',
    runtime => $config['runtime'],
  }

  cd4pe::runtime::run { $container['name']:
    runtime          => $config['runtime'],
    image            => $container['image'],
    net              => 'cd4pe',
    ports            => ['5432:5432'],
    volumes          => [
      "postgres:${postgres_dir}",
      "${preinit_script}:/docker-entrypoint-preinitdb.d/preinitdb.sh",
      "${init_script}:/docker-entrypoint-initdb.d/initdb.sql",
      "${conf_file}:${conf_destination}/postgresql.conf",
      "${hba_file}:${conf_destination}/pg_hba.conf",
      "${container['log_volume_name']}:${log_directory}",
    ],
    env              => [
      "POSTGRESQL_PASSWORD=${config['admin_db_password'].unwrap}",
      'BITNAMI_DEBUG=true',
    ],
    pull_on_start    => false,
    require          => [
      File[$init_script],
      File[$hba_file],
      File[$conf_file],
    ],
    extra_parameters => "--platform=linux/amd64 ${container['extra_parameters']}",
    before_stop      => "${config['runtime']} exec ${container['name']} pg_ctl stop --mode=fast --pgdata=${pgdata}",
  }

  cd4pe::logrotate_config { 'postgres':
    path            => "${cd4pe::runtime::volume_dir()}/${container['log_volume_name']}/_data/*.log",
    size_mb         => $config['max_log_size_mb'],
    post_rotate_cmd => "${config['runtime']} exec ${container['name']} pg_ctl logrotate --pgdata=${pgdata}",
    keep_files      => $config['keep_log_files'],
  }
}
