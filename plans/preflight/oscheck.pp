# @api private
# @summary Confirms the target system is running a supported OS and release
#
# @param config Cd4pe::Config config object from hiera
#
# @return JSON object with success and failure arrays
plan cd4pe::preflight::oscheck(
  Cd4pe::Config $config = cd4pe::config(),
) {
  $supported_versions = {
    'ubuntu' => [
      '18.04',
      '20.04',
    ],
    'rhel' => [
      '7',
      '8',
    ],
    'centos' => [
      '7',
      '8',
    ],
    'oraclelinux' => [
      '7',
      '8',
    ],
    'scientificlinux' => [
      '7',
      '8',
    ],
    'sles' => [
      '12',
    ],
    'redhat' => [
      '7',
      '8',
    ],
  }

  $supported_platform_arch = ['amd64', 'x86_64']
  $targets = $config['all_targets']

  $results = $targets.reduce({ 'passed' => [], 'failed' => [] }) |$memo, $target| {
    $facts_hash = $target.facts
    $name = $facts_hash['os']['name']
    $major = $facts_hash['os']['release']['major']
    $platform_arch = $facts_hash['os']['architecture']

    $arch_supported = $supported_platform_arch.any |$expected| { $expected == $platform_arch }
    if(!$supported_versions[$name.downcase] or !$supported_versions[$name.downcase].member($major) or !arch_supported) {
      $failed = $memo['failed'] << "${target} : found ${name} ${major} (${platform_arch})"
      $memo + { 'failed' => $failed }
    } else {
      $passed = $memo['passed'] << "${target} : found ${name} ${major} (${platform_arch})"
      $memo + { 'passed' => $passed }
    }
  }

  return $results
}
