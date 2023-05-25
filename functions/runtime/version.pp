function cd4pe::runtime::version(
  TargetSpec $target,
  Cd4pe::Runtime $runtime,
  Boolean $run_as_root = true,
) >> ResultSet {
  $command = $runtime ? {
    'docker' => "docker version -f '{{ json . }}'",
    'podman' => 'podman version -f json',
    default  => fail_plan("${runtime} is not yet implemented", 'cd4pe/error')
  }

  if($run_as_root) {
    return run_command($command, $target, '_run_as' => 'root', '_catch_errors' => 'true')
  }

  return run_command($command, $target, '_catch_errors' => 'true')
}
