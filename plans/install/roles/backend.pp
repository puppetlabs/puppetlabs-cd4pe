# @api private
#
# Calls the manifests needed to install and configure the backend role
#
# @param config Cd4pe::Config object with all config options
#
# @return Does not return anything
plan cd4pe::install::roles::backend(
  Cd4pe::Config $config,
) {
  $apply_options = {
    '_run_as' => 'root',
    '_description' => 'install and configure application components for role: Backend',
  }

  apply($config['roles']['backend']['targets'], $apply_options) {
    class { 'cd4pe':
      runtime => $config['runtime'],
    }

    class { 'cd4pe::component::pipelinesinfra':
      config => $config['roles']['backend']['services']['pipelinesinfra'],
    }

    class { 'cd4pe::component::query':
      config => $config['roles']['backend']['services']['query'],
    }
  }
}
