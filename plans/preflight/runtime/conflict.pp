# @api private
# 
# Docker and podman don't necessarily play very nicely together when run on the same system, so
# this plan looks for the 'other' container runtime (the one the customer has not specified as theirs) and
# returns a failure result if it is found on the target.
# 
# @param config Cd4pe::Config object with all config options
#
# @returns Hash returns pass/fail object for display
plan cd4pe::preflight::runtime::conflict(
  Cd4pe::Config $config = cd4pe::config
) {
  $desired_runtime = $config['runtime']
  $conflicting_runtime = $desired_runtime ? {
    'podman' => 'docker',
    default => 'podman'
  }

  $all_targets = $config['all_targets']

  $results = $all_targets.reduce({ 'passed' => [], 'failed' => [] }) |$memo, $target| {
    $runtime_results = cd4pe::runtime::version($target, $conflicting_runtime)
    $passed_targets = $runtime_results.error_set.map() |$result| {
      "${result.target.name} : No conflicting runtimes found"
    } + $memo['passed']
    $failed_targets = $runtime_results.ok_set.map() |$result| {
      "${result.target.name} : found conflicting runtime ${conflicting_runtime}"
    } + $memo['failed']
    $memo + { 'passed' => $passed_targets, 'failed' => $failed_targets }
  }

  return $results
}
