Puppet::Functions.create_function(:'cd4pe::compiling_server_osfamily') do
  def compiling_server_osfamily
    Facter.value('osfamily')
  end
end
