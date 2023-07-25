# Abstraction to allow for both podman and docker to run a container
# For docker, it leverages the docker module's existing `docker::run`
# For podman, it creates start and stop bash scripts and systemd service 
# file to run them to replicate what the docker module does for docker.
#
# @param runtime [Cd4pe::Runtime] The runtime to use to run the container
# @param image [String] The image to use as the base for the container
# @param net [Variant[String,Array[String[1],1],Undef]] The existing runtime network to connect to
# @param ports [Variant[String,Array,Undef]] A list of TCP ports to publish in the container
# @param volumes [Variant[String,Array,Undef]] A list of volumes to mount in the container
# @param env [Variant[String,Array]] A list of environment variables to set in the container
# @param env_file [Variant[String,Array]] A list of environment files to set in the container
# @param pull_on_start [Boolean] Whether to pull the image on start.  Not implemented for podman
# @param extra_parameters [Variant[String,Array[String],Undef]] Extra parameters to pass to the runtime
# @param before_stop [Variant[String,Boolean]] A command to run before stopping the container
define cd4pe::runtime::run (
  Cd4pe::Runtime $runtime,
  String $image,
  Variant[String,Array[String[1],1],Undef] $net = undef,
  Variant[String,Array,Undef] $ports = [],
  Variant[String,Array,Undef] $volumes = [],
  Variant[String,Array] $env = [],
  Variant[String,Array] $env_file = [],
  Boolean $pull_on_start = false,
  Variant[String,Array[String],Undef] $extra_parameters = undef,
  Variant[String,Boolean] $before_stop = false,
) {
  if($runtime == 'docker') {
    docker::run { $name:
      image            => $image,
      net              => $net,
      ports            => $ports,
      volumes          => $volumes,
      env              => $env,
      env_file         => $env_file,
      pull_on_start    => $pull_on_start,
      extra_parameters => $extra_parameters,
      before_stop      => $before_stop,
    }
  } elsif($runtime == 'podman') {
    $systemd_file = "/etc/systemd/system/podman-${name}.service"
    $start_script = "/usr/local/bin/podman-run-${name}-start.sh"
    $stop_script = "/usr/local/bin/podman-run-${name}-stop.sh"
    # create systemd service file
    file { $systemd_file:
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      show_diff => false,
      content   => epp('cd4pe/runtime/service.epp',
        {
          'title'           => $name,
      }),
    }

    # podman prepends "localhost" to the bitnami image name
    # so we need to update the image name to account for it
    if($image =~ /bitnami/) {
      $image_sanitized = "localhost/${image}"
    } else {
      $image_sanitized = $image
    }
    file { $start_script:
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0770',
      show_diff => false,
      content   => epp('cd4pe/runtime/service-start-script.epp',
        {
          'title'            => $name,
          'net'              => $net,
          'envs'             => $env,
          'env_files'        => $env_file,
          'ports'            => $ports,
          'volumes'          => $volumes,
          'extra_parameters' => $extra_parameters,
          'image'            => $image_sanitized,
      }),
    }

    file { $stop_script:
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0770',
      show_diff => false,
      content   => epp('cd4pe/runtime/service-stop-script.epp',
        {
          'title'       => $name,
          'before_stop' => $before_stop,
      }),
    }

    service { "podman-${name}":
      ensure    => running,
      provider  => 'systemd',
      hasstatus => true,
      require   => [
        File[$systemd_file],
        File[$start_script],
        File[$stop_script],
      ],
      subscribe => [
        File[$systemd_file],
        File[$start_script],
        File[$stop_script],
      ],
    }

    exec { "podman-${name}-systemd-reload":
      path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      require     => [
        File[$systemd_file],
        File[$start_script],
        File[$stop_script],
      ],
      subscribe   => [
        File[$systemd_file],
        File[$start_script],
        File[$stop_script],
      ],
    }

    Exec["podman-${name}-systemd-reload"] -> Service <| title == "podman-${name}" |>

    [File[$systemd_file], File[$start_script], File[$stop_script],] ~> Service <| title == "podman-${name}" |>
  } else {
    fail("Unsupported runtime: ${runtime}")
  }
}
