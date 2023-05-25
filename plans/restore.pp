# @summary Restore CD4PE
# Given a target with a fresh CD4PE installation of the same version as the backup,
# this plan will restore the database and docker volumes from a given backup zip archive.
#
# @param backup The name of the backup created by cd4pe::backup.  For example "cd4pe-backup-2023-04-05-01-01-01-01.zip"
#
plan cd4pe::restore(
  String[1] $backup,
) {
  $config = cd4pe::config()
  $target = $config['roles']['backend']['targets'][0]
  $runtime = $config['runtime']

  without_default_logging() || {
    $preflight_results = run_plan(
      'cd4pe::restore::preflight',
      'config' => $config,
      'backup' => $backup,
    )

    if($preflight_results != '') {
      fail_plan($preflight_results)
    }
  }

  # bring down pfi, query, and ui
  apply_prep($target, { '_run_as' => 'root' })
  $stop_apply_options = {
    '_run_as' => 'root',
    '_description' => 'Stop CD4PE services',
  }

  apply($target, $stop_apply_options) {
    service { "${runtime}-pipelinesinfra":
      ensure => stopped,
    }
    service { "${runtime}-query":
      ensure => stopped,
    }
    service { "${runtime}-ui":
      ensure => stopped,
    }
  }

  # Gather database information and run the restore task
  $db_role = $config['roles']['database']['services']['postgres']

  $database_info = Cd4pe::Support_bundle::Database_info.new({
      'container_name' => $db_role['container']['name'],
      'database_user'  => $db_role['admin_db_username'],
  })

  $host = $config['roles']['backend']['targets'][0]
  $restore_result = run_task(
    'cd4pe::restore',
    # TODO: Currently only supports a single target
    $host,
    {
      'runtime'        => $runtime,
      'backup_dir'     => $config['backup_dir'],
      'backup_archive' => $backup,
      'database_info'  => $database_info,
      'image'          => $config['images']['pipelinesinfra'],
      '_run_as'        => 'root',
      '_catch_errors'  => true,
    }
  )

  if($restore_result[0].ok) {
    $restore_result[0].value['warnings'].each |$warning| {
      out::message($warning)
    }
    out::message($restore_result[0].value['message'])
  } else {
    $error_message = @("ERROR")
      Restore failed:
        ${restore_result[0].value['message']}
        ${restore_result[0].value['error']}
      Check the bolt-debug.log for additional details.
      | ERROR
    fail_plan($error_message)
  }

  # Restart the services
  $start_apply_options = {
    '_run_as' => 'root',
    '_description' => 'Start CD4PE services',
  }
  apply($target, $start_apply_options) {
    service { "${runtime}-pipelinesinfra":
      ensure => running,
    }
    service { "${runtime}-query":
      ensure => running,
    }
    service { "${runtime}-ui":
      ensure => running,
    }
  }

  out::message('Restore complete.  Note that if the database passwords have been changed, you will need to re-run')
  out::message('bolt plan run cd4pe::install to update the passwords and allow the services to properly start.')
}
