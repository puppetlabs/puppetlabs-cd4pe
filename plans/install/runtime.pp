# @api private
#
# Installs the desired runtime on all infrastucture targets.
# 
# For a list of supported runtimes, @see Cd4pe::Runtime
#
# @param config  Cd4pe::Config object with all config options 
#
# @return ResultSet from catalog application
plan cd4pe::install::runtime(
  Cd4pe::Config $config,
) {
  apply_prep($config['all_targets'], { '_run_as' => 'root' })
  $runtime = $config['runtime']

  $apply_options = {
    '_run_as' => 'root',
    '_description' => "install ${runtime}",
  }

  if($runtime == 'docker') {
    return apply($config['all_targets'], $apply_options) {
      include docker
    }
  } elsif($runtime == 'podman') {
    return apply($config['all_targets'], $apply_options) {
      package { ['podman', 'podman-plugins']:
        ensure => present,
      }
    }
  } else {
    fail_plan("${runtime} is not supported. Please update the configuration to be either docker or podman", 'cd4pe/error')
  }
}
