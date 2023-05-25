# @api private
#
# Validates that the provided infrstructure setup is supported
#
# @param config Cd4pe::Config config object from hiera
#
# @return Hash containing failed and passed arrays
plan cd4pe::preflight::architecture (
  Cd4pe::Config $config = cd4pe::config()
) {
  $hosts = $config['all_targets']

  if ($hosts.length == 1) {
    $result = {
      'passed' => ['Infrastructure setup is supported'],
      'failed' => [],
    }
  } else {
    $result = {
      'passed' => [],
      'failed' => ["Expected all target hosts to be the same but got ${hosts.join(', ')}"],
    }
  }

  return $result
}
