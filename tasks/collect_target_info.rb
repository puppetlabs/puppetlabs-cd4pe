#!/opt/puppetlabs/puppet/bin/ruby
require "json"
require "tmpdir"
require "open3"
require "fileutils"
# This task exists to minimize the number of SSH connections used by the collection of data from a CD4PE installation

# @param [String] tmpdir Destination for collected system info
def collect_system_info(tmpdir)
  system_dir = File.join(tmpdir, "system")
  Dir.mkdir(system_dir)
  commands = [
    { 'name' => 'top', 'command' => 'top -bn 5' },
    { 'name' => 'vmstat', 'command' => 'vmstat 1 5' },
    { 'name' => 'iostat', 'command' => 'iostat 1 5' },
    { 'name' => 'meminfo', 'command' => 'cat /proc/meminfo' },
    { 'name' => 'cpuinfo', 'command' => 'cat /proc/cpuinfo' },
    { 'name' => 'df_h', 'command' => 'df --human-readable' },
    { 'name' => 'df_i', 'command' => 'df --inodes' },
    { 'name' => 'iptables', 'command' => 'iptables --verbose --list' },
    { 'name' => 'iptables_nat', 'command' => 'iptables --table nat --verbose --list' },
    { 'name' => 'systemctl', 'command' => 'systemctl list-units' },
    { 'name' => 'uptime', 'command' => 'uptime' },
    { 'name' => 'netstat', 'command' => 'netstat --all --numeric --program --tcp --udp --timers' },
    { 'name' => 'dmesg', 'command' => 'dmesg --ctime --time-format iso' },
  ]

  # All calls to capture2e end with semi-colon so that the command forces shell invocation. This is done so the command can
  # exit with code 127 if it doesn't exist. Without the semi-colon an exception is raised. See:
  # https://stackoverflow.com/questions/26040249/why-does-open3-popen3-return-wrong-error-when-executable-is-missing
  commands.each do |command|
    combined_output, _ = Open3.capture2e("#{command['command']};")
    File.write(File.join(system_dir, "#{command['name']}.txt"), combined_output)
  end
end

# Collect container runtime info
# @param [String] runtime Used to gather information from the container runtime
# @param [String] tmpdir Destination for collected system info
def collect_runtime_info(tmpdir, runtime)
  runtime_commands = [
    { 'name' => 'network_ls', 'command' => "#{runtime} network ls" },
    { 'name' => 'volume_ls', 'command' => "#{runtime} volume ls" },
    { 'name' => 'ps', 'command' => "#{runtime} ps --all" },
    { 'name' => 'journalctl', 'command' => "journalctl --output cat --unit #{runtime}" },
  ]

  runtime_dir = File.join(tmpdir, 'runtime')
  Dir.mkdir(runtime_dir)

  runtime_commands.each do |command|
    combined_output, _ = Open3.capture2e("#{command['command']};")
    File.write(File.join(runtime_dir, "#{command['name']}.txt"), combined_output)
  end

  containers_dir = File.join(runtime_dir, 'containers')
  Dir.mkdir(containers_dir)
  container_ls_output, _ = Open3.capture2e("#{runtime} container ls -q")
  container_ls_output.split("\n").each do |container_id|
    combined_output, _ = Open3.capture2e("#{runtime} container inspect #{container_id};")
    container_info = JSON.parse(combined_output)
    name = container_info[0]['Name']
    redacted_container_info = redact_container_info(container_info)
    File.write(File.join(containers_dir, "#{name}.json"), JSON.pretty_generate(redacted_container_info))
  end

  volumes_dir = File.join(runtime_dir, 'volumes')
  Dir.mkdir(volumes_dir)
  volume_ls_output, _ = Open3.capture2e("#{runtime} volume ls -q")
  volume_ls_output.split("\n").each do |volume_id|
    combined_output, _ = Open3.capture2e("#{runtime} volume inspect #{volume_id};")
    volume_info = JSON.parse(combined_output)
    name = volume_info[0]['Name']
    File.write(File.join(volumes_dir, "#{name}.json"), JSON.pretty_generate(volume_info))
  end

  networks_dir = File.join(runtime_dir, 'networks')
  Dir.mkdir(networks_dir)
  network_ls_output, _ = Open3.capture2e("#{runtime} network ls -q")
  network_ls_output.split("\n").each do |volume_id|
    combined_output, _ = Open3.capture2e("#{runtime} network inspect #{volume_id};")
    network_info = JSON.parse(combined_output)
    name = network_info[0]['Name']
    File.write(File.join(networks_dir, "#{name}.json"), JSON.pretty_generate(network_info))
  end

end

# @param [Hash] container_info The output of running a container inspect command.
# Should be the same across all container runtimes.
def redact_container_info(container_info)
  allow_list = [
    'ANALYTICS',
    'APP_VERSION',
    'BITNAMI_APP_NAME',
    'BITNAMI_DEBUG',
    'BOLT_DISABLE_ANALYTICS',
    'CD4PE_BACKEND_SERVICE_ENDPOINT',
    'CD4PE_BOLT_PCP_READ_TIMEOUT_SEC',
    'CD4PE_CONFIG',
    'CD4PE_DOCKER',
    'CD4PE_EULA_ACCEPTED',
    'CD4PE_FAILED_LOGIN_ATTEMPT_PERIOD_IN_MINS',
    'CD4PE_HTTP_CONNECTION_TIMEOUT_SEC',
    'CD4PE_HTTP_READ_TIMEOUT_SEC',
    'CD4PE_HTTP_REQUEST_TIMEOUT_SEC',
    'CD4PE_HTTP_WRITE_TIMEOUT_SEC',
    'CD4PE_INCLUDE_GIT_HISTORY_FOR_CD4PE_JOBS',
    'CD4PE_JOB_GLOBAL_TIMEOUT',
    'CD4PE_JOB_HTTP_READ_TIMEOUT',
    'CD4PE_LDAP_GROUP_SEARCH_SIZE_LIMIT',
    'CD4PE_LOCKOUT_PERIOD_IN_MINS',
    'CD4PE_MAX_LOGIN_ATTEMPTS',
    'CD4PE_QUERY_SERVICE_TOKEN_PATH',
    'CD4PE_QUERY_SERVICE_TOKEN_SECRET_NAME',
    'CD4PE_REPO_CACHE_RETRIEVAL_TIMEOUT_MINUTES',
    'CD4PE_REPO_CACHING',
    'CD4PE_ROOT_EMAIL',
    'CD4PE_ROUTE_PREFIX',
    'CD4PE_SECURE_COOKIE',
    'CD4PE_SERVICE',
    'CD4PE_STAGE',
    'CD4PE_STORAGE_BUCKET',
    'CD4PE_STORAGE_PROVIDER',
    'CD4PE_WEBSERVER_PORT',
    'CD4PE_WEB_UI_ENDPOINT',
    'COMMIT_SHA',
    'DB_ENDPOINT',
    'DB_SCHEMA',
    'DB_USER',
    'ENABLE_REPORT_TEMPLATES',
    'GOSU_VERSION',
    'HOME',
    'JAVA_HOME',
    'JAVA_VERSION',
    'JVM_ARGS',
    'LANG',
    'LANGUAGE',
    'LOG4J_PATH',
    'LOGGING',
    'LOG_LEVEL',
    'NGINX_VERSION',
    'NJS_VERSION',
    'NSS_WRAPPER_LIB',
    'OS_ARCH',
    'OS_FLAVOUR',
    'OS_NAME',
    'OTEL_CONFIG_SAMPLER_PROBABILITY',
    'OTEL_EXPORTER',
    'OTEL_EXPORTER_JAEGER_ENDPOINT',
    'OTEL_EXPORTER_JAEGER_SERVICE_NAME',
    'OTEL_EXPORTER_LOGGING_PREFIX',
    'OTEL_METRICS_EXPORTER',
    'OTEL_RESOURCE_ATTRIBUTES',
    'OTEL_TRACES_EXPORTER',
    'PATH',
    'PGDATA',
    'PG_MAJOR',
    'PG_VERSION',
    'PKG_RELEASE',
    'PLAYGROUND',
    'POSTGRES_DB',
    'POSTGRES_USER',
    'PUPPET_TEAMS_WEB_UI_ENDPOINT',
    'PUPPETDB_CONNECTION_TIMEOUT_SEC',
    'QUERY_COMPLEXITY_LIMIT',
    'QUERY_SERVICE',
    'TEAMS_UI_ENDPOINT',
    'TEAMS_UI_VERSION',
    'TMP',
    'WORKSPACE_URL',
  ]

  container_info[0]['Config']['Env'].map! do |env|
    # if the string starts with a string not in the allow_list
    # set the string to "*** REDACTED ***"
    # otherwise leave it alone
    env_var_name = env[/(.*?)=/, 1]
    unless allow_list.include?(env_var_name)
      env[/=(.*)/, 1] = '[*** REDACTED ***]'
    end
    env
  end
  container_info
end

# Collect log data for each service
# @param [String] tmpdir Destination for collected logs
# @param [String] runtime Used to construct the correct systemd unit name needed to collect logs.
# @param [Array] journald_services A mapping of role to service names of journald logs to collect
def collect_logs(tmpdir, runtime, journald_services)
  log_dir = File.join(tmpdir, 'logs')
  Dir.mkdir(log_dir)
  journald_services.each do |role_services|
    role_log_dir = File.join(log_dir, role_services['role_name'])
    Dir.mkdir(role_log_dir)
    role_services['services'].each do |service|
      service_dir = File.join(role_log_dir, service)
      Dir.mkdir(service_dir)
      combined_output, _ = Open3.capture2e("journalctl --output cat --unit #{runtime}-#{service};")
      File.write(File.join(service_dir, "#{service}-journald.log"), combined_output)
    end
  end
end

# Run queries against the CD4PE database to collect data.
# @param [Hash] database_info Contains info needed to connect to the database.
# @param [String] tmpdir Destination for collected database info.
# @param [String] runtime Used to execute the psql command from within the container.
# @param [String] task_dir The absolute path to the directory of the running Bolt task.
def collect_database_info(database_info, tmpdir, runtime, task_dir)
  db_dir = File.join(tmpdir, 'database')
  Dir.mkdir(db_dir)
  # Collect db table sizes
  File.open(File.join(task_dir, 'cd4pe', 'files', 'support_bundle', 'sql', 'table_sizes.sql'), 'r') do |sql_file|
    combined_output, _ = Open3.capture2e("#{runtime} exec -i #{database_info['container_name']} psql -P pager=off -U #{database_info['database_user']} -f -;", :stdin_data => sql_file.read)
    File.write(File.join(db_dir, 'table_sizes.txt'), combined_output)
  end
end

params = JSON.parse(STDIN.read)
tmpdir = Dir.mktmpdir

collect_system_info(tmpdir)
collect_runtime_info(tmpdir, params['runtime'])
collect_logs(tmpdir, params['runtime'], params['journald_services'])
# Collect db info if applicable
if params['database_info'] != nil
  collect_database_info(params['database_info'], tmpdir, params['runtime'], params['_installdir'])
end

output = { "tmpdir" => tmpdir }
puts output.to_json