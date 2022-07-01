# This is the structure of a simple plan. To learn more about writing
# Puppet plans, see the documentation: http://pup.pt/bolt-puppet-plans

# The summary sets the description of the plan that will appear
# in 'bolt plan show' output. Bolt uses puppet-strings to parse the
# summary and parameters from the plan.
# @summary A plan created with bolt plan new.
# @param targets The targets to run on.
plan cd4pe::install (
  TargetSpec $targets = 'localhost'
) {
  out::message('Installing CD4PE')

  $save_result = run_task('cd4pe::save_containers', 'localhost').first
  out::message($save_result)
  $containers_file = $save_result['value']['containers_file']
  out::message($containers_file)
  upload_file($containers_file, '/etc/cd4pe/', $targets, _run_as => 'root')

  apply_prep($targets)
  $apply_result = apply($targets, _catch_errors => true, _run_as => 'root') {
    include cd4pe
  }
  out::message('Finished applying CD4PE Puppet module')
  out::message($apply_result)
  return $apply_result
}
