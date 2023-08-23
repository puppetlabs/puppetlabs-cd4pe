require 'bolt'

Puppet::Functions.create_function(:'cd4pe::bolt_version') do
  dispatch :bolt_version do
    return_type 'String[1]'
  end

  def bolt_version
    Bolt::VERSION
  end
end
