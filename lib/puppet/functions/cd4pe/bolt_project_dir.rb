Puppet::Functions.create_function(:'cd4pe::bolt_project_dir') do
  dispatch :bolt_project_dir do
    return_type 'String[1]'
  end

  def bolt_project_dir
    Puppet.lookup(:bolt_project).to_s
  end
end
