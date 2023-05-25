Puppet::Functions.create_function(:'cd4pe::bolt_project_inventory_targets') do
  dispatch :bolt_project_inventory_targets do
    return_type 'Array[Target]'
  end

  def bolt_project_inventory_targets
    inventory = Puppet.lookup(:bolt_inventory)
    return inventory.get_targets(inventory.target_names.to_a)
  end
end
