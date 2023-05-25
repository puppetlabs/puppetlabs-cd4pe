# @api private
#
# Checks localhost for the existence of a container runtime that will be used in the installation process.
#
# @param config Cd4pe::Config object with all config options
#
# @returns result object with pass/fail information
plan cd4pe::preflight::runtime::local(
  Cd4pe::Config $config = cd4pe::config(),
) {
  $desired_runtime = $config['runtime']

  $version_result = cd4pe::runtime::version('localhost', $desired_runtime, false)

  if(!$version_result.error_set.empty) {
    $result = {
      'passed' => [],
      'failed' => ["Could not find ${desired_runtime} on Bolt runner, please install it to proceed."],
    }
  } else {
    $result = {
      'passed' => ["Found ${desired_runtime}"],
      'failed' => [],
    }
  }

  return $result
}
