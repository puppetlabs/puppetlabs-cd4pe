# @api private
#
# Runs cleanup tasks after a successful upgrade
#
# @param config Cd4pe::Config object with all config options
#
# @return Does not return anything
plan cd4pe::upgrade::cleanup(
  Cd4pe::Config $config
) {
  $prune_result = without_default_logging() || {
    run_command(
      "${config['runtime']} image prune --all --force",
      $config['all_targets'],
      { '_run_as' => 'root', '_catch_errors' => true },
    )
  }

  $prune_result.error_set.targets.each |$target| {
    out::message("[WARNING] ${target}: could not clean up unused images")
  }
}
