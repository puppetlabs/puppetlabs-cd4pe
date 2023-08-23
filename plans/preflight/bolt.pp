# @api private
#
# Validates that the installed bolt version is supported
#
# @return Hash containing failed and passed arrays
plan cd4pe::preflight::bolt () {
  $min_version = '3.27.2'
  $installed_version = cd4pe::bolt_version()

  if (versioncmp($installed_version, $min_version) < 0) {
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
