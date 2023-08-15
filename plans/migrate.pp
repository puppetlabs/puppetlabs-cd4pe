# @summary Migrate config and data from a 4.x CD4PE install
plan cd4pe::migrate() {
  $inventory_targets = cd4pe::bolt_project_inventory_targets()

  if $inventory_targets.size == 0 {
    fail_plan('No inventory file exists. Please create one first. See https://puppet.com/docs', 'cd4pe/error')
  } elsif $inventory_targets.size == 1 {
    fail_plan('Inventory file found with one target, minimum two required. Please add a node with kubectl access'
      + ' to your CD4PE 4 kubernetes cluster, and another on which to install CD4PE 5.', 'cd4pe/error')
  } else {
    out::message('Inventory file found with multiple targets')
  }

  $cd4pe_4_target = prompt::menu('Select CD4PE 4 host', $inventory_targets)
  $cd4pe_5_target = prompt::menu('Select target to install CD4PE 5 on', $inventory_targets)

  # Grab configuration from the 4.x instance and write it out to hiera
  run_plan('cd4pe::migrate::config', {
    cd4pe_4_target => $cd4pe_4_target,
    cd4pe_5_target => $cd4pe_5_target,
  })
}
