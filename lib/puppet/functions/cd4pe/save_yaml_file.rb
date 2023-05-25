require 'yaml'
require 'fileutils'

# Takes a hash object, calls .to_yaml and saves it to disk
Puppet::Functions.create_function(:'cd4pe::save_yaml_file') do
  # @param data A hash to write as yaml
  # @param relative_file_path path relative to the bolt project
  # @return The absolute file path of where it was saved
  dispatch :save_yaml_file do
    param 'Hash', :data
    param 'String', :relative_file_path
    return_type 'String[1]'
  end

  def save_yaml_file(data, relative_file_path)
    boltdir = call_function('cd4pe::bolt_project_dir')
    abs_file_path = File.expand_path(relative_file_path, boltdir)
    FileUtils.mkdir_p(File.dirname(abs_file_path))
    File.open(abs_file_path,"w") do |file|
        file.write data.to_yaml
    end
    return abs_file_path
  end
end
