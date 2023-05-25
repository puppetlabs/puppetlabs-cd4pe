Puppet::Functions.create_function(:'cd4pe::bolt_project_files_dir') do
  dispatch :bolt_project_files_dir do
    return_type 'String[1]'
  end

  def bolt_project_files_dir
    Puppet.lookup(:bolt_project).path.to_s + '/files'
  end
end
