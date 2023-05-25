# @api private
#
# A plan to check whether the target machine(s) meet(s) our total memory requirements
#
# @param config Cd4pe::Config config object from hiera
# 
# @return Hash A hash with pass and/or fail messages
plan cd4pe::preflight::memorycheck(
  Cd4pe::Config $config = cd4pe::config()
) {
  $targets = $config['all_targets']

  $required_memory_bytes = 8000000000
  $required_memory_gib = '7.45 GiB'

  $results = $targets.reduce({ passed => [], failed => [] }) |$memo, $target| {
    $facts_from_target = get_target($target).facts()
    $found_memory_bytes = $facts_from_target['memory']['system']['total_bytes']
    $found_memory_gib = $facts_from_target['memory']['system']['total']

    if($found_memory_bytes <= $required_memory_bytes) {
      $failed = $memo['failed'] << "${target} : found ${found_memory_gib}"
      $memo + { 'failed' => $failed }
    } else {
      $passed = $memo['passed'] << "${target} : found ${found_memory_gib}"
      $memo + { 'passed' => $passed }
    }
  }

  return $results
}
