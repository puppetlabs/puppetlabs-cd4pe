# Creates a volume for the given name using the configured
# runtime (docker or podman).  Docker leverages the docker
# module's `docker_volume` resource, while podman uses an
# `exec` resource to directly create the volume
#
# @param ensure [Enum] The desired state of the volume
# @param runtime [String] The runtime to use for creating the volume
define cd4pe::runtime::volume (
  Enum['present','absent'] $ensure = 'present',
  Cd4pe::Runtime $runtime = 'docker',
) {
  if($runtime == 'docker') {
    docker_volume { $name:
      ensure => $ensure,
    }
  } elsif($runtime == 'podman') {
    if($ensure == 'present') {
      exec { "podman volume create ${name}":
        path   => '/usr/bin',
        unless => "podman volume inspect ${name}",
      }
    } else {
      exec { "podman volume rm ${name}":
        path   => '/usr/bin',
        onlyif => "podman volume inspect ${name}",
      }
    }
  } else {
    fail("Unsupported runtime in volume create: ${runtime}")
  }
}
