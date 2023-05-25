# Cd4pe configuration that customers can change
type Cd4pe::Hiera_config = Struct[{
    targets             => Struct[{
        backend  => Array[String[1]],
        database => Array[String[1]],
        ui       => Array[String[1]],
    }],
    analytics           => Boolean,
    admin_db_password   => String[1],
    cd4pe_db_password   => String[1],
    cd4pe_db_username   => Optional[String[1]],
    query_db_password   => String[1],
    query_db_username   => Optional[String[1]],
    resolvable_hostname => String[1],
    root_password       => String[1],
    root_username       => String[1],
    runtime             => Optional[Cd4pe::Runtime],
    secret_key          => String[16],
    backup_dir          => Optional[String[1]],
    containers          => Optional[Struct[{
          teams_ui => Optional[Struct[{
                max_log_size_mb  => Optional[Integer[1]],
                keep_log_files   => Optional[Integer[0]],
                extra_parameters => Optional[String[1]],
          }]],
          postgres => Optional[Struct[{
                log_level        => Optional[Enum['INFO', 'NOTICE', 'WARNING', 'ERROR']],
                max_log_size_mb  => Optional[Integer[1]],
                keep_log_files   => Optional[Integer[0]],
                extra_parameters => Optional[String[1]],
          }]],
          pipelinesinfra => Optional[Struct[{
                log_level        => Optional[Enum['info', 'debug', 'trace']],
                max_log_size_mb  => Optional[Integer[1]],
                keep_log_files   => Optional[Integer[0]],
                extra_parameters => Optional[String[1]],
          }]],
          query => Optional[Struct[{
                log_level        => Optional[Enum['INFO', 'DEBUG', 'TRACE']],
                max_log_size_mb  => Optional[Integer[1]],
                keep_log_files   => Optional[Integer[0]],
                extra_parameters => Optional[String[1]],
          }]],
    }]],

    # PipelinesInfra advanced config
    job_http_read_timeout_mins        => Optional[Integer],
    job_global_timeout_mins           => Optional[Integer],
    ldap_group_search_size_limit      => Optional[Integer],
    repo_caching                      => Optional[Boolean],
    repo_cache_retrieval_timeout_mins => Optional[Integer],
    bolt_pcp_read_timeout_secs        => Optional[Integer],
    include_git_history_for_jobs      => Optional[Boolean],
    http_connection_timeout_secs      => Optional[Integer],
    http_read_timeout_secs            => Optional[Integer],
    http_write_timeout_secs           => Optional[Integer],
    http_request_timeout_secs         => Optional[Integer],
    puppetdb_connection_timeout_secs  => Optional[Integer],
    max_login_attempts                => Optional[Integer],
    failed_login_attempt_period_mins  => Optional[Integer],
    lockout_period_mins               => Optional[Integer],

    # query service advanced config
    enable_report_templates           => Optional[Boolean],
    query_complexity_limit            => Optional[Integer[1]],
}]
