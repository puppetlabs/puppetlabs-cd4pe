# @api private
#
# Extracts config settings from the 4.x install and creates a hiera config file for the new 5.x install with them.
plan cd4pe::install::from_4x::generate_config(
  Target $cd4pe_4_target,
  Target $cd4pe_5_target,
  String $hostname,
  String $runtime,
  Sensitive[String] $admin_db_password,
  Sensitive[String] $console_root_password,
) {
  $root_email = run_command(
    'kubectl get secret cd4pe-root -o jsonpath=\'{.data.email}\' | base64 -d',
    $cd4pe_4_target
  )[0].value['stdout']

  $db_secret_key = run_command(
    'kubectl get secret cd4pe-pfi -o jsonpath=\'{.data.pfiSecretKey}\' | base64 -d',
    $cd4pe_4_target
  )[0].value['stdout']

  $cd4pe_db_creds = run_command(
    'kubectl get secret cd4pe-postgres -o jsonpath=\'{.data}\'', $cd4pe_4_target)[0].value['stdout'].parsejson
  $cd4pe_db_user = base64('decode', $cd4pe_db_creds['user'])
  $cd4pe_db_password = base64('decode', $cd4pe_db_creds['password'])

  $query_db_creds = run_command(
    'kubectl get secret query-postgres -o jsonpath=\'{.data}\'', $cd4pe_4_target)[0].value['stdout'].parsejson
  $query_db_user = base64('decode', $query_db_creds['POSTGRES_USER'])
  $query_db_password = base64('decode', $query_db_creds['POSTGRES_PASSWORD'])

  $pod_env_vars = run_command('kubectl get pod -l app.kubernetes.io/name=cd4pe -o jsonpath="{.items[0].spec.containers[0].env}"',
    $cd4pe_4_target)[0].value['stdout'].parsejson
  $env_hash = cd4pe::migrate::env_to_hash($pod_env_vars)

  $optional_settings = {
    # PipelinesInfra advanced settings
    'job_http_read_timeout_mins'        => cd4pe::maybe_to_int($env_hash['CD4PE_JOB_HTTP_READ_TIMEOUT_MINUTES']),
    'job_global_timeout_mins'           => cd4pe::maybe_to_int($env_hash['CD4PE_JOB_GLOBAL_TIMEOUT_MINUTES']),
    'ldap_group_search_size_limit'      => cd4pe::maybe_to_int($env_hash['CD4PE_LDAP_GROUP_SEARCH_SIZE_LIMIT']),
    'repo_cache_retrieval_timeout_mins' => cd4pe::maybe_to_int($env_hash['CD4PE_REPO_CACHE_RETRIEVAL_TIMEOUT_MINUTES']),
    'bolt_pcp_read_timeout_secs'        => cd4pe::maybe_to_int($env_hash['CD4PE_BOLT_PCP_READ_TIMEOUT_SEC']),
    'http_connection_timeout_secs'      => cd4pe::maybe_to_int($env_hash['CD4PE_HTTP_CONNECTION_TIMEOUT_SEC']),
    'http_read_timeout_secs'            => cd4pe::maybe_to_int($env_hash['CD4PE_HTTP_READ_TIMEOUT_SEC']),
    'http_write_timeout_secs'           => cd4pe::maybe_to_int($env_hash['CD4PE_HTTP_WRITE_TIMEOUT_SEC']),
    'http_request_timeout_secs'         => cd4pe::maybe_to_int($env_hash['CD4PE_HTTP_REQUEST_TIMEOUT_SEC']),
    'puppetdb_connection_timeout_secs'  => cd4pe::maybe_to_int($env_hash['PUPPETDB_CONNECTION_TIMEOUT_SEC']),
    'max_login_attempts'                => cd4pe::maybe_to_int($env_hash['CD4PE_MAX_LOGIN_ATTEMPTS']),
    'failed_login_attempt_period_mins'  => cd4pe::maybe_to_int($env_hash['CD4PE_FAILED_LOGIN_ATTEMPT_PERIOD_IN_MINS']),
    'lockout_period_mins'               => cd4pe::maybe_to_int($env_hash['CD4PE_LOCKOUT_PERIOD_IN_MINS']),
    'repo_caching'                      => cd4pe::maybe_to_bool($env_hash['CD4PE_REPO_CACHING']),
    'include_git_history_for_jobs'      => cd4pe::maybe_to_bool($env_hash['CD4PE_INCLUDE_GIT_HISTORY_FOR_CD4PE_JOBS']),

    # Query Service advanced settings
    'enable_report_templates'           => cd4pe::maybe_to_bool($env_hash['ENABLE_REPORT_TEMPLATES']),
    'query_complexity_limit'            => cd4pe::maybe_to_int($env_hash['QUERY_COMPLEXITY_LIMIT']),
  }

  run_plan('cd4pe::generate_config', {
      admin_password       => $console_root_password,
      admin_username       => $root_email,
      secret_key           => Sensitive($db_secret_key),
      admin_db_password    => $admin_db_password,
      cd4pe_db_password    => Sensitive($cd4pe_db_password),
      cd4pe_db_username    => $cd4pe_db_user,
      query_db_password    => Sensitive($query_db_password),
      query_db_username    => $query_db_user,
      inventory_aio_target => $cd4pe_5_target.name,
      resolvable_hostname  => $hostname,
      runtime              => $runtime,
      optional_settings    => $optional_settings,
  })
}
