# This profile may be enforced on your PE master or it may be applied as a
# one-time action. It configures the Puppet Enterprise console with a standard
# environment node group configuration for use with cd4pe.
#
# This class can be applied as a one-time configuration action using e.g.
#
#     puppet apply <<EOF
#     class { 'cd4pe::environment_node_groups':
#       environments => [
#         'production',
#         'staging',
#         'development',
#       ],
#     }
#     EOF
#
# From the above example, environment node groups will then be configured as:
#
#    All Nodes (N/A)
#    └── All Environments (production)
#        ├── Agent-specified environment (agent-specified)
#        ├── Development environment (development)
#        │   └── Development one-time run exception (agent-specified)
#        ├── Production environment (production)
#        │   └── Production one-time run exception (agent-specified)
#        └── Staging environment (staging)
#            └── Staging one-time run exception (agent-specified)
#
class cd4pe::environment_node_groups (
  Pattern[/\A[a-z0-9_]+\Z/]        $default_environment = 'production',
  Array[Pattern[/\A[a-z0-9_]+\Z/]] $environments        = ['production'],
  Boolean                          $manage_one_time_run_exception_rule = true,
) {

  ##################################################
  # ENVIRONMENT GROUPS
  ##################################################

  node_group { 'All Environments':
    ensure               => present,
    description          => 'Environment group parent and default',
    environment          => $default_environment,
    override_environment => true,
    parent               => 'All Nodes',
    rule                 => ['and', ['~', 'name', '.*']],
  }

  node_group { 'Agent-specified environment':
    ensure               => present,
    description          => 'This environment group exists for unusual testing and development only. Expect it to be empty',
    environment          => 'agent-specified',
    override_environment => true,
    parent               => 'All Environments',
    rule                 => [ ],
  }

  # We'll set the rule to allow runs if --environment=<foo> by default. The
  # class can be configured not to mangage this rule though, for example if
  # one-time run exceptions are not allowed, or must be tuned per-environment
  # group.
  $one_time_run_exception_rule = $manage_one_time_run_exception_rule ? {
    true  => ['and', ['~', ['fact', 'agent_specified_environment'], '.+']],
    false => undef,
  }

  $environments.each |$env| {
    $title_env = capitalize($env)

    node_group { "${title_env} environment":
      ensure               => present,
      environment          => $env,
      override_environment => true,
      parent               => 'All Environments',
    }

    node_group { "${title_env} one-time run exception":
      ensure               => present,
      description          => "Allow ${env} nodes to request a different puppet environment for a one-time run",
      environment          => 'agent-specified',
      override_environment => true,
      parent               => "${title_env} environment",
      rule                 => $one_time_run_exception_rule,
    }
  }

}
