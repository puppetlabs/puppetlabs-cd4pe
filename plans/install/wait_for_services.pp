# @api private
#
# Waits until we get a 200 healthy status response back from the
# CD4PE api endpoint.
#
# @param config Cd4pe::Config config object
#
# @return This plan does not return anything
plan cd4pe::install::wait_for_services(
  Cd4pe::Config $config = cd4pe::config()
) {
  $is_healthy = cd4pe::status_check($config['roles']['backend']['services']['pipelinesinfra']['resolvable_hostname'])
  if !$is_healthy {
    fail_plan('Services did not come up within expected time frame', 'cd4pe/error')
  }
}
