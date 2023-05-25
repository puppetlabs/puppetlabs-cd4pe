# @api private
#
# Calls the manifests needed to install and configure the UI role
#
# @param config Cd4pe::Config object with all config options
#
# @return Does not return anything
plan cd4pe::install::roles::ui(
  Cd4pe::Config $config,
) {
  run_plan('cd4pe::install::configure_ssl_termination',
    config => $config,
  )

  $apply_options = {
    '_run_as' => 'root',
    '_description' => 'install and configure application components for role: UI ',
  }

  apply($config['roles']['ui']['targets'], $apply_options) {
    class { 'cd4pe':
      runtime => $config['runtime'],
    }

    class { 'cd4pe::component::teams_ui':
      config => $config['roles']['ui']['services']['ui'],
    }
  }
}
