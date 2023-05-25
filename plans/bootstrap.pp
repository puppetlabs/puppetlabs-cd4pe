# @summary Interactive plan that prompts you for configuration information
#
# Prompts you to answer questions to generate the configuration hiera data
# file for use with cd4pe::install
#
# All sensitive data will be encrypted with hiera-eyaml
#
# You must have an inventory.yaml file first.
plan cd4pe::bootstrap(
) {
  out::message('Checking if an inventory file exists')
  $inventory_targets = cd4pe::bolt_project_inventory_targets()

  if $inventory_targets.size == 0 {
    fail_plan('No inventory file exists. Please create one first. See https://puppet.com/docs', 'cd4pe/error')
  } elsif $inventory_targets.size == 1 {
    out::message('Inventory file found with one target.')
    $use_inventory_target = Boolean(prompt("Use target ${inventory_targets[0].name} for AIO install?", 'default' => 'yes'))
    if !$use_inventory_target {
      fail_plan('No other inventory targets found, please add more to your inventory file and run again')
    } else {
      $inventory_aio_target = $inventory_targets[0]
    }
  } else {
    out::message('Inventory file found with multiple targets')
    $inventory_aio_target = prompt::menu('which inventory target to use?', $inventory_targets)
  }

  $hostname =  prompt('What is the resolvable hostname of the CD4PE web console?', 'default' => $inventory_aio_target.uri)

  $admin_uname = prompt('Console admin username', 'default' => 'admin')
  $admin_pword =  prompt('Console admin password', 'sensitive' => true)

  $collect_analytics =  Boolean(prompt('Permission to send analytic data to puppet.com', 'default' => 'true'))
  $auto_config_db = Boolean(prompt('Would you like to auto-configure the database users and passwords?', 'default' => 'true'))
  if $auto_config_db {
    $admin_db_password = Sensitive(cd4pe::secure_random(32))
    $cd4pe_db_password = Sensitive(cd4pe::secure_random(32))
    $cd4pe_db_username = 'cd4pe'
    $query_db_password = Sensitive(cd4pe::secure_random(32))
    $query_db_username = 'query'
  } else {
    $admin_db_password = prompt('administrator database password', 'sensitive' => true)
    $cd4pe_db_username = prompt('cd4pe database username', 'default' => 'cd4pe')
    $cd4pe_db_password = prompt('cd4pe database password', 'sensitive' => true)
    $query_db_username = prompt('query database username', 'default' => 'query')
    $query_db_password = prompt('query database password', 'sensitive' => true)
  }

  run_plan('cd4pe::generate_config', {
      admin_password       => $admin_pword,
      admin_username       => $admin_uname,
      analytics            => $collect_analytics,
      admin_db_password    => $admin_db_password,
      cd4pe_db_password    => $cd4pe_db_password,
      cd4pe_db_username    => $cd4pe_db_username,
      query_db_password    => $query_db_password,
      query_db_username    => $query_db_username,
      inventory_aio_target => $inventory_aio_target.name,
      resolvable_hostname  => $hostname,
  })
}
