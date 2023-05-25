# @summary Backup CD4PE
# @return nothing
plan cd4pe::backup() {
  $config = cd4pe::config()

  # Run the validate plan to ensure the target is in good shape before backing up
  $validate_output = run_plan('cd4pe::validate')
  if($validate_output['failed'].length() > 0) {
    fail_plan('Target failed validation. Re-run the install plan to correct the installation before running a backup.')
  }

  $db_role = $config['roles']['database']['services']['postgres']

  $database_info = Cd4pe::Support_bundle::Database_info.new({
      'container_name' => $db_role['container']['name'],
      'database_user'  => $db_role['admin_db_username'],
  })

  $roles = $config['roles']
  $volumes = [
    {
      'container' => $roles['backend']['services']['pipelinesinfra']['container']['name'],
      'name'      => $roles['backend']['services']['pipelinesinfra']['container']['log_volume_name'],
    },
    {
      'container' => $roles['backend']['services']['query']['container']['name'],
      'name'      => $roles['backend']['services']['query']['container']['log_volume_name'],
    },
    {
      'container' => $roles['database']['services']['postgres']['container']['name'],
      'name'      => $roles['database']['services']['postgres']['container']['log_volume_name'],
    },
    {
      'container' => $roles['ui']['services']['ui']['container']['name'],
      'name'      => $roles['ui']['services']['ui']['container']['log_volume_name'],
    },
    {
      'container' => $roles['backend']['services']['pipelinesinfra']['container']['name'],
      'name'      => 'cd4pe-query-service-token',
    },
  ]

  $host = $config['roles']['backend']['targets'][0]
  $result = run_task(
    'cd4pe::backup',
    # TODO: Currently only supports a single target
    $host,
    {
      'runtime'       => $config['runtime'],
      'backup_dir'    => $config['backup_dir'],
      'database_info' => $database_info,
      'volumes'       => $volumes,
      'image'         => $config['images']['pipelinesinfra'],
      'version'       => cd4pe::module_version(),
      '_run_as'       => 'root',
      '_catch_errors' => true,
    }
  )
  if($result[0].ok) {
    $archive = $result[0].value['backup_archive']
    $error_message = @("SUCCESS")
      Backup complete. The resulting file is ${archive} on ${$host}
      Make sure this file is on distributed storage or backed up to an external location for safety.
      | SUCCESS
    out::message($error_message)
  } else {
    $error_message = @("ERROR")
      Backup failed:
        ${result[0].value['message']}
        ${result[0].value['error']}
      Check the bolt-debug.log for additional details.
      | ERROR
    out::message($error_message)
  }
}
