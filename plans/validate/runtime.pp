# @api private
#
# Validates that we have a runtime installed on all infrastructure targets.
#
# @param config Cd4pe::Config object with all config options
#
# @return Hash returns pass/fail results from check
plan cd4pe::validate::runtime (
  Cd4pe::Config $config = cd4pe::config(),
) {
  $runtime = $config['runtime']

  $results = $config['roles'].reduce({ 'failed' => [], 'passed' => [] }) |$memo, $roles_hash| {
    $role = $roles_hash[0]
    $targets = $roles_hash[1]['targets']

    $runtime_results = cd4pe::runtime::version($targets, $runtime)
    $passed_targets = $runtime_results.ok_set.map() |$result| {
      "${result.target.name} : found ${runtime}"
    } + $memo['passed']
    $failed_targets = $runtime_results.error_set.map() |$result| {
      "${result.target.name} : ${runtime} not found"
    } + $memo['failed']

    $memo + { 'passed' => $passed_targets.unique, 'failed' => $failed_targets.unique }
  }

  return $results
}
