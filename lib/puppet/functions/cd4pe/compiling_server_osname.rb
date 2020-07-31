Puppet::Functions.create_function(:'cd4pe::compiling_server_osname') do
  def compiling_server_osname
    Facter.value('os')['name']
  end
end
