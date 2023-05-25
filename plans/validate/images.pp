# @api private
#
# Validates that we have the expected images on all targets based on their role
#
# @param config Cd4pe::Config object with all config options
#
# @return Hash pass/fail results of check
plan cd4pe::validate::images (
  Cd4pe::Config $config = cd4pe::config(),
) {
  $results = $config['roles'].reduce({ passed => [], failed => [] }) |$memo, $roles_hash| {
    $role_name = $roles_hash[0]
    $targets = $roles_hash[1]['targets']
    $services = $roles_hash[1]['services']
    $images_validation_results = $services.reduce($memo) |$memo, $service_hash| {
      $service_name = $service_hash[0]
      $image = $service_hash[1]['container']['image']
      $inspect_result = cd4pe::images::inspect($image, $targets)
      $failed_targets = $inspect_result.error_set.map() |$result| {
        "${result.target.name} : could not find image for container ${service_name}"
      } + $memo['failed']
      $passed_targets = $inspect_result.ok_set.map() |$result| {
        "${result.target.name} : found image ${service_name}"
      } + $memo['passed']

      (
        $memo + {
          'passed' => $passed_targets,
          'failed' => $failed_targets
        }
      )
    }
    (
      $memo + {
        'passed' => $images_validation_results['passed'],
        'failed' => $images_validation_results['failed']
      }
    )
  }
  return $results
}
