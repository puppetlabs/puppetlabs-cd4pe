# cd4pe::runtime::volume_dir
# Returns the directory where volumes are stored for the current runtime
# @return [String] The directory where volumes are stored
function cd4pe::runtime::volume_dir(
) >> String {
  $runtime = lookup('cd4pe::config.runtime', undef, undef, 'docker')
  $volume_dir = $runtime ? {
    'podman' => '/var/lib/containers/storage/volumes',
    'docker' => '/var/lib/docker/volumes',
    default  => '/var/lib/docker/volumes',
  }

  return $volume_dir
}
