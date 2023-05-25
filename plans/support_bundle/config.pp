# @api private
#
# Collects local configuration information from CD4PE
#
# This plan doesn't return anything, as all failures are soft failures
# as the data gathering is meant to be best effort to account for users
# having variations in their installed packages.
#
# @param config_root_dir     Absolute path to where the plan will store config data
plan cd4pe::support_bundle::config(
  Cd4pe::Config $config,
  String[1] $config_root_dir,
) {
  $absolute_system_path = file::join($config_root_dir, 'config')
  run_command("mkdir ${absolute_system_path}", 'localhost')

  file::write(file::join($absolute_system_path, 'config.json'), to_json_pretty($config))
}
