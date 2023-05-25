# @summary List backups in the backup directory available for restore
# @return none
plan cd4pe::list_backups() {
  $config = cd4pe::config()

  $target = $config['roles']['backend']['targets'][0]

  without_default_logging() || {
    $ls_cmd = "ls --human-readable --format=long ${config['backup_dir']}/cd4pe-backup-*.zip"
    $ls_results = run_command($ls_cmd, $target, '_run_as' => 'root', '_catch_errors' => true)
    $backups_without_metadata = $ls_results[0].value['stdout'].split("\n").map |$line| {
      $fields = $line.split(/\s+/)
      Hash.new({
          'name' => $fields[8],
          'size' => $fields[4],
      })
    }

    $backups = $backups_without_metadata.map |$backup| {
      $zipfile = basename($backup['name'])
      $dir = $zipfile[0,-('.zip'.length()+1)]
      $metadata_cmd = "unzip -p ${backup['name']} ${dir}/metadata.json"
      $metadata_results = run_command($metadata_cmd, $target, '_run_as' => 'root', '_catch_errors' => true)
      $metadata = $metadata_results[0]['stdout'].parsejson
      $backup + { 'version' => $metadata['version'] }
    }
    if($ls_results.ok) {
      out::message("Backup directory '${config['backup_dir']}' on ${target}")
    }
    out::message(cd4pe::backup::format_results($backups))
    if(!$ls_results.ok) {
      out::message("No backups found in backup directory '${config['backup_dir']}' on ${target}.")
    }
  }
}
