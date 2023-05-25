# @summary Configuration values for CD4PE
#
# Values are populated from both user input via {Cd4pe::Hiera_config}
# and hard-coded application defaults.
#
# This Datatype can be new-ed up using the function {Cd4pe::Config()}
#
# @example running a command against all CD4PE infra targets
#   $config = Cd4pe::Config()
#   $targets = $config['all_targets']
#   run_command($targets, 'whoami')
type Cd4pe::Config = Struct[{
    all_targets                  => Array[Target],
    images                       => Struct[{
        teams_ui       => String[1],
        pipelinesinfra => String[1],
        query          => String[1],
        postgres       => String[1],
    }],
    roles               => Cd4pe::Roles,
    runtime             => Cd4pe::Runtime,
    backup_dir          => String[1],
    dump_filename       => String[1],
}]
