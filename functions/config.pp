# Creates a fully populated config object that contains both
# user data from hiera, and hard coded application config data.
#
# To avoid this object becoming monstrious, it should only contain values
# that are shared across multiple plans and manifest code.
function cd4pe::config() >> Cd4pe::Config {
  $hiera_config = lookup('cd4pe::config', Cd4pe::Hiera_config, 'deep', undef)
  $images = lookup('cd4pe::images')

  $query_db_username = cd4pe::default_for_value($hiera_config['query_db_username'], 'query')
  $cd4pe_db_username = cd4pe::default_for_value($hiera_config['cd4pe_db_username'], 'cd4pe')
  $runtime = cd4pe::default_for_value($hiera_config['runtime'], 'docker')
  $backup_dir = cd4pe::default_for_value($hiera_config['backup_dir'], '/var/lib/puppetlabs/cd4pe/backups')


  $container_defaults = {
    teams_ui => {
      max_log_size_mb => 100,
      keep_log_files => 3,
      extra_parameters => undef,
    },
    pipelinesinfra => {
      max_log_size_mb => 200,
      keep_log_files => 5,
      log_level => 'info',
      extra_parameters => undef,
    },
    postgres => {
      max_log_size_mb => 100,
      keep_log_files => 3,
      log_level => 'ERROR',
      extra_parameters => undef,
    },
    query => {
      max_log_size_mb => 100,
      keep_log_files => 3,
      log_level => 'DEBUG',
      extra_parameters => undef,
    },
  }
  $containers = $container_defaults + cd4pe::default_for_value($hiera_config['containers'], {})
  $ui_service = Cd4pe::Config::Teams_ui.new({
      analytics         => $hiera_config['analytics'],
      container         => Cd4pe::Container.new({
          name             => 'ui',
          image            => $images['teams_ui'],
          log_volume_name  => 'ui-logs',
          extra_parameters => $containers['teams_ui']['extra_parameters'],
      }),
      console_log_level => 'info',
      max_log_size_mb   => $containers['teams_ui']['max_log_size_mb'],
      keep_log_files    => $containers['teams_ui']['keep_log_files'],
      runtime           => $runtime,
      teams_ui_version  => '4.14.0',
  })

  $pipelinesinfra_service = Cd4pe::Config::Pipelinesinfra.new({
      analytics           => $hiera_config['analytics'],
      backup_dir          => $backup_dir,
      container           => Cd4pe::Container.new({
          name             => 'pipelinesinfra',
          image            => $images['pipelinesinfra'],
          log_volume_name  => 'pipelinesinfra-logs',
          extra_parameters => $containers['pipelinesinfra']['extra_parameters'],
      }),
      db_username         => $cd4pe_db_username,
      db_password         => Sensitive($hiera_config['cd4pe_db_password']),
      log_level           => $containers['pipelinesinfra']['log_level'],
      max_log_size_mb     => $containers['pipelinesinfra']['max_log_size_mb'],
      keep_log_files      => $containers['pipelinesinfra']['keep_log_files'],
      resolvable_hostname => $hiera_config['resolvable_hostname'],
      root_password       => Sensitive($hiera_config['root_password']),
      root_username       => $hiera_config['root_username'],
      runtime             => $runtime,
      secret_key          => Sensitive($hiera_config['secret_key']),
      secret_key_path     => '/etc/puppetlabs/cd4pe/secret_key',
      env_vars => {
        'CD4PE_JOB_HTTP_READ_TIMEOUT'                => $hiera_config['job_http_read_timeout_mins'],
        'CD4PE_JOB_GLOBAL_TIMEOUT'                   => $hiera_config['job_global_timeout_mins'],
        'CD4PE_LDAP_GROUP_SEARCH_SIZE_LIMIT'         => $hiera_config['ldap_group_search_size_limit'],
        'CD4PE_REPO_CACHING'                         => $hiera_config['repo_caching'],
        'CD4PE_REPO_CACHE_RETRIEVAL_TIMEOUT_MINUTES' => $hiera_config['repo_cache_retrieval_timeout_mins'],
        'CD4PE_BOLT_PCP_READ_TIMEOUT_SEC'            => $hiera_config['bolt_pcp_read_timeout_secs'],
        'CD4PE_INCLUDE_GIT_HISTORY_FOR_CD4PE_JOBS'   => $hiera_config['include_git_history_for_jobs'],
        'CD4PE_HTTP_CONNECTION_TIMEOUT_SEC'          => $hiera_config['http_connection_timeout_secs'],
        'CD4PE_HTTP_READ_TIMEOUT_SEC'                => $hiera_config['http_read_timeout_secs'],
        'CD4PE_HTTP_WRITE_TIMEOUT_SEC'               => $hiera_config['http_write_timeout_secs'],
        'CD4PE_HTTP_REQUEST_TIMEOUT_SEC'             => $hiera_config['http_request_timeout_secs'],
        'PUPPETDB_CONNECTION_TIMEOUT_SEC'            => $hiera_config['puppetdb_connection_timeout_secs'],
        'CD4PE_MAX_LOGIN_ATTEMPTS'                   => $hiera_config['max_login_attempts'],
        'CD4PE_FAILED_LOGIN_ATTEMPT_PERIOD_IN_MINS'  => $hiera_config['failed_login_attempt_period_mins'],
        'CD4PE_LOCKOUT_PERIOD_IN_MINS'               => $hiera_config['lockout_period_mins'],
      },
  })

  $query_service = Cd4pe::Config::Query.new({
      analytics               => $hiera_config['analytics'],
      container               => Cd4pe::Container.new({
          name             => 'query',
          image            => $images['query'],
          log_volume_name  => 'query-logs',
          extra_parameters => $containers['query']['extra_parameters'],
      }),
      db_username         => $query_db_username,
      db_password         => Sensitive($hiera_config['query_db_password']),
      log_level       => $containers['query']['log_level'],
      max_log_size_mb => $containers['query']['max_log_size_mb'],
      keep_log_files  => $containers['query']['keep_log_files'],
      resolvable_hostname     => $hiera_config['resolvable_hostname'],
      runtime                 => $runtime,
      db_endpoint => cd4pe::default_for_value($hiera_config['db_endpoint'], 'postgres://postgres:5432'),
      env_vars                => {
        'ENABLE_REPORT_TEMPLATES' => $hiera_config['enable_report_templates'],
        'QUERY_COMPLEXITY_LIMIT'  => $hiera_config['query_complexity_limit'],
      },
  })

  $postgres_service = Cd4pe::Config::Postgres.new({
      analytics   => $hiera_config['analytics'],
      container   => Cd4pe::Container.new({
          name             => 'postgres',
          image            => $images['postgres'],
          log_volume_name  => 'postgres-logs',
          extra_parameters => $containers['postgres']['extra_parameters'],
      }),
      admin_db_password => Sensitive($hiera_config['admin_db_password']),
      admin_db_username => 'postgres',
      cd4pe_db_password => Sensitive($hiera_config['cd4pe_db_password']),
      cd4pe_db_username => $cd4pe_db_username,
      query_db_password => Sensitive($hiera_config['query_db_password']),
      query_db_username => $query_db_username,
      log_level => $containers['postgres']['log_level'],
      max_log_size_mb => $containers['postgres']['max_log_size_mb'],
      keep_log_files => $containers['postgres']['keep_log_files'],
      runtime     => $runtime,
  })

  Cd4pe::Config.new({
      all_targets => get_targets($hiera_config['targets'].values.flatten.unique),
      images      => $images,
      roles       => Cd4pe::Roles.new({
          ui => {
            services => { ui => $ui_service },
            targets  => get_targets($hiera_config['targets']['ui']),
          },
          backend => {
            services => {
              pipelinesinfra => $pipelinesinfra_service,
              query => $query_service,
            },
            targets  => get_targets($hiera_config['targets']['backend']),
          },
          database => {
            services => {
              postgres => $postgres_service,
            },
            targets  => get_targets($hiera_config['targets']['database']),
          },
      }),
      runtime       => $runtime,
      backup_dir    => $backup_dir,
      dump_filename => "cd4pe-postgres-${Timestamp.new.strftime('%Y-%m-%d')}.dump",
  })
}
