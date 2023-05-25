Puppet::Functions.create_function(:'cd4pe::module_version', Puppet::Functions::InternalFunction) do
  dispatch :module_version do
    scope_param
  end

  def module_version(scope)
    scope.compiler.environment.module('cd4pe').version
  end
end
