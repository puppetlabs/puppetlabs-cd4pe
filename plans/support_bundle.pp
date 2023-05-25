#
# @summary Generates troubleshooting diagnostic data
# 
# This plan gathers gathers informations detailing the state of an existing CD4PE installation.
# The information is stored in a compressed directory we call the 'support bundle'.
# The idea is that customers will hand it off to support further troubleshooting by them and developers.
#
# @param [String[1]] identifier
#   An identifier, such as a support ticket number
# @param [Boolean] compress
#   Specifies whether or not the resulting directory should be compressed using tar/gzip
plan cd4pe::support_bundle(
  Optional[String[1]] $identifier = undef,
  Optional[Boolean] $compress = true,
) {
  $config = cd4pe::config()
  out::message('Generating support bundle. This may take several minutes...')
  if($identifier != undef) {
    if($identifier !~ /^[a-zA-Z0-9\-\_]*$/) {
      fail_plan("The supplied identifier '${identifier}' must contain only letters, numbers, dashes, or underscores")
    }
    $id = "${identifier}-"
  } else {
    $id = ''
  }
  $support_bundle_dir_name = "supportbundle-${id}${Timestamp.new.strftime('%Y-%m-%dT%H_%M_%S')}"
  $downloads_path = cd4pe::download_dir()
  if (!file::exists($downloads_path)) {
    without_default_logging() || {
      run_command("mkdir -p ${downloads_path}", 'localhost')
    }
  }
  $support_bundle_path = file::join($downloads_path, $support_bundle_dir_name)
  if (file::exists($support_bundle_path)) {
    fail_plan("Failed to generate support bundle because path already exists at:\n '${support_bundle_path}'\n Try re-running the plan.")
  }
  without_default_logging() || {
    run_command("mkdir ${support_bundle_path}", 'localhost')
  }

  out::message('Collecting target info...')
  run_plan('cd4pe::support_bundle::collect_target_info', 'config' => $config, 'root_dir' => $support_bundle_path)

  out::message('Collecting configuration information from the CD4PE module..')
  run_plan(
    'cd4pe::support_bundle::config',
    'config_root_dir' => $support_bundle_path,
    'config' => $config,
  )

  # These commands must come last because as this plan runs it will also log to bolt-debug.log so
  # we need to copy it after running the other commands so we don't miss anything.
  out::message('Adding Bolt debug log to support bundle..')
  without_default_logging() || {
    run_command("cp ${cd4pe::bolt_project_dir()}/bolt-debug.log ${support_bundle_path}", 'localhost')
  }

  if($compress) {
    $tar_path = file::join($downloads_path, "${support_bundle_dir_name}.tar.gz")
    without_default_logging() || {
      run_command("tar czf ${tar_path} --directory=${downloads_path} ${support_bundle_dir_name}", 'localhost')
    }
    out::message("Generated support bundle at ${$tar_path}")
    $output_path = $tar_path
    # The -r flag of the rm command requires that all files be writable. 
    # Our plan may create files that aren't if the user's umask doesn't allow for it.
    without_default_logging() || {
      run_command("rm -r ${support_bundle_path}", 'localhost')
    }
  } else {
    $output_path = $support_bundle_path
    out::message("Generated support bundle directory at ${$support_bundle_path}")
  }

  $output = { 'support_bundle_path' => $output_path }
  return $output
}
