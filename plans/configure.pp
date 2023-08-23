# @summary Update the configuration of CD4PE, based on hiera data.
plan cd4pe::configure() {
  # For now, updating is accomplished by just rerunning the install plan,
  # which will read the config and make any required changes to the deployed
  # application.
  run_plan('cd4pe::install::install_app')
}
