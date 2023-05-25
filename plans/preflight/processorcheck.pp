# @api private
# 
# A plan to check whether the target machine(s) meet(s) our processor requirements
#
# @param config Cd4pe::Config config object from hiera
#
# @return Hash A hash with pass and/or fail messages 
plan cd4pe::preflight::processorcheck(
  Cd4pe::Config $config = cd4pe::config(),
) {
  $targets = $config['all_targets']

  $required_processors_count = 4

  $results = $targets.reduce({ passed => [], failed => [] }) | $memo, $target| {
    $facts_from_target = $target.facts()
    $found_processors_count = $facts_from_target['processors']['count']

    if($found_processors_count < $required_processors_count) {
      $failed = $memo['failed'] << "${target} : found ${found_processors_count} CPUs"
      $memo + { 'failed' => $failed }
    } else {
      $passed = $memo['passed'] << "${target} : found ${found_processors_count} CPUs"
      $memo + { 'passed' => $passed }
    }
  }

  return $results
}
