Puppet::Functions.create_function(:'cd4pe::file_dirname') do
  dispatch :file_dirname do
    param 'String', :path
    return_type 'String[1]'
  end

  def file_dirname(path)
    File.dirname(path)
  end
end
