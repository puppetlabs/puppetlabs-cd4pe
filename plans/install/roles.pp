# @api private
#
# Calls the manifests needed to install and configure all roles
#
# @param config Cd4pe::Config object with all config optiosn
#
# @return Does not return anything
plan cd4pe::install::roles(
  Cd4pe::Config $config
) {
  run_plan('cd4pe::install::roles::database',
    config => $config,
  )

  run_plan('cd4pe::install::roles::backend',
    config => $config,
  )

  run_plan('cd4pe::install::roles::ui',
    config => $config,
  )
}
