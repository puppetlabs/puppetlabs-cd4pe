# cd4pe::runtime::volume
# Returns a volume definition for the given runtime.  Specifically adding
# the :z flag for podman to allow SELinux to work properly.
# @param [String] $volume_source The source of the volume
# @param [String] $volume_dest The destination of the volume
# @return [String] The volume definition
function cd4pe::runtime::volume(
  String $volume_source,
  String $volume_dest,
) >> String {
  $config = cd4pe::config()
  $volume_def = $config['runtime'] ? {
    'docker' => "${volume_source}:${volume_dest}",
    'podman' => "${volume_source}:${volume_dest}:z",
    default  => fail_plan("${runtime} is not yet implemented", 'cd4pe/error')
  }

  return $volume_def
}
