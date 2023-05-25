# @api private
#
# @summary Collects info from all CD4PE targets
# 
# This plan gathers data from all CD4PE targets so it can be included in the support bundle. A large portion of the data is collected by
# the 'collect_target_info' task which is done to optimize the number of SSH sessions we use as a consequence of data collection. It allows
# us to have one task collect most of the target specific data. The plan also collects facter data from each target. Log volumes for each 
# container service are downloaded as well.
#
# @param [Cd4pe::Config] config
# @param [String[1]] root_dir
#   The destination directory for collected target info.
plan cd4pe::support_bundle::collect_target_info(
  Cd4pe::Config $config,
  String[1] $root_dir,
) {
  $roles_for_targets = $config['all_targets'].reduce({}) |$memo, $target| {
    $matching_roles = $config['roles'].filter |$role_name, $role_value| {
      $role_value['targets'].any |$found_target| { $target == $found_target }
    }
    $memo + { $target => $matching_roles }
  }

  $target_data_dest = file::join($root_dir, 'targets')
  without_default_logging() || {
    run_command("mkdir ${target_data_dest}", 'localhost')
    $config['all_targets'].each |$target| {
      run_command("mkdir ${file::join($target_data_dest, $target.name)}", 'localhost')
    }
  }

  $collect_info_results = run_task_with(
    'cd4pe::collect_target_info',
    $config['all_targets'],
    '_run_as'       => 'root',
    '_catch_errors' => true,
  ) |$target| {
    $roles = $roles_for_targets[$target]
    # Calculate what Journald logs should be collected
    $journald_services = $roles.map |$role_name, $role_value| {
      Cd4pe::Support_bundle::Journald_services.new({
        'role_name' => $role_name,
        'services'  => $role_value['services'].keys
      })
    }
    # If applicable, provides the info needed by the task to connect to the database in order to run diagnostic queries.
    # This works for AIO, but when we have multiple targets that can have the DB role, we'll just want the task to run on the main DB
    # target.
    if $roles['database'] != undef {
      $database_info = Cd4pe::Support_bundle::Database_info.new({
          'container_name' => $roles['database']['services']['postgres']['container']['name'],
          'database_user'  => $roles['database']['services']['postgres']['admin_db_username'],
      })
    }
    $target_params = {
      'runtime' => $config['runtime'],
      'journald_services' => $journald_services,
      'database_info' => $database_info,
    }
    $target_params
  }
  without_default_logging() || {
    # Download the tmp dir from the target
    $collect_info_results.each |$result| {
      $src_tmpdir = $result.value['tmpdir']
      cd4pe::download_file($src_tmpdir, file::join($target_data_dest, $result.target.name), $result.target, { '_run_as' => 'root' }, true)
      run_command("rm -r ${result.value['tmpdir']}", $result.target, '_run_as' => 'root', '_catch_errors' => true)
    }

    # Download log volumes for each target
    $roles_for_targets.each |$target, $roles| {
      $roles.each |$role_name, $role_value| {
        $role_value['services'].each |$service_name, $service_value| {
          $volume_src = $config['runtime'] ? {
            'docker' => file::join('/var/lib/docker/volumes', $service_value['container']['log_volume_name'], '_data'),
            default => fail_plan("Can't collect log volumes for unsupported runtime: ${config['runtime']}")
          }
          $service_dest = file::join($target_data_dest, $target.name, 'logs', $role_name, $service_name)
          cd4pe::download_file($volume_src, $service_dest, $target, { '_run_as' => 'root', '_catch_errors' => true }, true)
        }
      }
    }

    # Collect facts
    $facter_keys = [
      'load_averages',
      'memory',
      'disks',
      'mountpoints',
      'os',
      'partitions',
      'processors',
    ]
    out::message('Gathering facts from targets...')
    # Needed so facts are pulled from the target
    apply_prep($config['all_targets'], { '_run_as' => 'root' })
    $config['all_targets'].each |$target| {
      $facts_hash = $target.facts
      $facter_result = $facter_keys.reduce({}) |$fact_memo, $key| {
        if($key in $facts_hash) {
          $fact_memo + { $key => $facts_hash[$key] }
        } else {
          $fact_memo
        }
      }
      $facts_dest_path = file::join($target_data_dest, $target.name, 'system')
      file::write(file::join($facts_dest_path, 'facter.json'), to_json_pretty($facter_result))
    }
  }
}
