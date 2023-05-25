# Subtype of {Cd4pe::Config} that is passed to puppet
# code for configuring the Teams-ui component.
#
# Important: DataTypes used here must be serializable, or come
# from puppet modules since they are passed to target nodes.
type Cd4pe::Config::Teams_ui = Struct[{
    analytics         => Boolean,
    container         => Cd4pe::Container,
    runtime           => Cd4pe::Runtime,
    console_log_level => String[1],
    max_log_size_mb   => Integer[1],
    keep_log_files    => Integer[0],
    teams_ui_version  => String[1],
}]
