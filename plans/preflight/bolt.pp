# @api private
#
# Validates that the installed bolt version is supported
#
# @return Hash containing failed and passed arrays
plan cd4pe::preflight::bolt () {
  $min_version = '3.0.0'
  $command = 'bolt --version'
  $command_result = run_command($command, 'localhost', '_catch_errors' => true)

  $installed_version = $command_result[0].status ? {
    'success' => $command_result[0].value['stdout'].chomp,
    default => undef,
  }

  if ($installed_version == undef) {
    $error = $command_result[0].value['stdout']
    $exit_code = $command_result[0].value['exit_code']
    $result = {
      'passed' => [],
      'failed' => [
        "Could not verify installed Bolt version. Received exit code ${exit_code}: \"${error.chomp}\" while executing \"${command}\".",
      ],
    }
  } elsif (versioncmp($installed_version, $min_version) < 0) {
    $result = {
      'passed' => [],
      'failed' => ["Found Bolt version ${installed_version} but expected version >= ${min_version}."],
    }
  } else {
    $result = {
      'passed' => ["Bolt version ${installed_version} is supported."],
      'failed' => [],
    }
  }

  return $result
}
