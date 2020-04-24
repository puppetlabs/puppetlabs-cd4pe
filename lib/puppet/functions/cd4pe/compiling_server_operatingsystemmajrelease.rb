Puppet::Functions.create_function(:'cd4pe::compiling_server_operatingsystemmajrelease') do
  def compiling_server_operatingsystemmajrelease
    Facter.value('operatingsystemmajrelease')
  end
end
