function cd4pe::runtime::version(
  TargetSpec $target,
  Cd4pe::Runtime $runtime,
  Boolean $run_as_root = true,
) >> ResultSet {
  $command = $runtime ? {
    # Check for Docker in the output to ensure it is not the podman-docker shim
    'docker' => 'docker version |grep --ignore-case docker',
    # In case a docker-podman shim exists somewhere, doublecheck it is actually podman
    'podman' => 'podman version |grep --ignore-case podman',
    default  => fail_plan("${runtime} is not yet implemented", 'cd4pe/error')
  }

  if($run_as_root) {
    return run_command($command, $target, '_run_as' => 'root', '_catch_errors' => 'true')
  }

  return run_command($command, $target, '_catch_errors' => 'true')
}
