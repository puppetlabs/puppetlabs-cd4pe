# @api private
#
# A plan to check whether the configured infra is fit for CD4PE restore and
# prints results. Specifically checks whether the postgres database is up and
# the version of the backup matches the current module version.
# @param config Cd4pe::Config config object from hiera
#
# @param backup String[1] The name of the backup zip archive to restore
#
# @returns message String[1] An error message if the preflight check fails
plan cd4pe::restore::preflight(
  Cd4pe::Config $config,
  String[1] $backup,
) {
  $target = $config['roles']['backend']['targets'][0]

  # confirm backup is the same version as the current module version
  $metadata_cmd = "unzip -p ${config['backup_dir']}/${backup} ${backup[0,-('.zip'.length()+1)]}/metadata.json"
  $metadata_results = run_command($metadata_cmd, $target, '_run_as' => 'root', '_catch_errors' => true,)
  if(!$metadata_results.ok) {
    $message = @("ERROR")
      Unable to extract metadata.json from backup archive:
        ${metadata_results[0].error}
      Confirm it was created with cd4pe::backup.
      | ERROR
    return($message)
  }
  $metadata = $metadata_results[0]['stdout'].parsejson
  if($metadata['version'] != cd4pe::module_version()) {
    $message = @("ERROR")
      Backup version ${metadata['version']} does not match current module version ${cd4pe::module_version()}.
      The backup must be restored using the same version of the module that generated it.
      | ERROR
    return($message)
  }

  # Check if postgres is up.  We need it to be running in order to restore the SQL file from the backup
  # TODO: When we add support for multiple database targets, we'll need to run against the right one
  $runtime = $config['runtime']
  $sql_command = '\l'
  $db_subcommand = "psql --user postgres --command \"${sql_command}\""
  $db_command = "${runtime} exec postgres ${db_subcommand}"
  $db_connect_results = run_command(
    $db_command,
    $target,
    { '_run_as' => 'root', '_catch_errors' => true, },
  )
  if(!$db_connect_results.ok) {
    $message = @("ERROR")
      Unable to connect to postgres database:
        ${db_connect_results[0]['stderr']}
      Run 'cd4pe::install' to install or correct the CD4PE installation.
      | ERROR
    return($message)
  }

  return ''
}
