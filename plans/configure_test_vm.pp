plan cd4pe::configure_test_vm (
  TargetSpec $targets,
  Hash       $root_config,
  Hash       $user_config,
  Hash       $workspace_config,
) {

  run_task('cd4pe::root_configuration', $targets, $root_config)
  run_task('cd4pe::create_user',        $targets, $user_config)
  run_task('cd4pe::create_workspace',   $targets, $workspace_config)

}