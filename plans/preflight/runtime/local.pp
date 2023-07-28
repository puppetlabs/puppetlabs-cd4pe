# @api private
#
# Checks localhost for the existence of a container runtime that will be used in the installation process.
#
# @returns result object with pass/fail information
plan cd4pe::preflight::runtime::local() {
  $supported_runtimes = ['docker', 'podman']

  $supported_runtimes.each |$runtime| {
    if(cd4pe::runtime::version('localhost', $runtime, false).error_set.empty) {
      return({
          'passed' => ["Found ${runtime} command on path"],
          'failed' => [],
      })
    }
  }

  return({
      'passed' => [],
      'failed' => ["Could not find ${join($supported_runtimes, ' or ')} on Bolt runner, please install a container runtime to proceed."],
  })
}
