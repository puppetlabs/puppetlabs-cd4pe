# @api private
#
# Generates a Hiera config file with settings extracted from a 4.x install.
# Prompts the user for some values that cannot be pulled from the existing install.
plan cd4pe::install::from_4x::bootstrap() {
  # This function will return an empty list if no inventory file exists, or
  # if the file exists with no targets in it.
  $inventory_targets = cd4pe::bolt_project_inventory_targets()

  if $inventory_targets.size == 0 {
    fail_plan('No targets found. Please create an inventory file. See <migration docs>.')
  }

  $cd4pe_4_target = prompt::menu('Select target with access to CD4PE 4 host', $inventory_targets)
  $cd4pe_5_target = prompt::menu('Select target to install CD4PE 5 on', $inventory_targets)
  $hostname = prompt(
    'What is the resolvable hostname of the CD4PE web console for the new install?',
    'default' => $cd4pe_5_target.uri
  )

  $runtime = prompt::menu('Which container runtime should be installed on the target?', ['docker', 'podman'])
  $console_root_password = prompt('Choose a password for the root CD4PE user', 'sensitive' => true)
  $admin_db_password = prompt('Choose an admin password for the database', 'sensitive' => true)

  run_plan('cd4pe::install::from_4x::generate_config', {
    cd4pe_4_target        => $cd4pe_4_target,
    cd4pe_5_target        => $cd4pe_5_target,
    hostname              => $hostname,
    runtime               => $runtime,
    admin_db_password     => $admin_db_password,
    console_root_password => $console_root_password,
  })
}
