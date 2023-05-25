# Subtype of {Cd4pe::Config} that is passed to puppet
# code for configuring the Postgres component.
#
# Important: DataTypes used here must be serializable, or come
# from puppet modules since they are passed to target nodes.
type Cd4pe::Config::Postgres = Struct[{
    analytics         => Boolean,
    container         => Cd4pe::Container,
    admin_db_password => Sensitive[String[1]],
    admin_db_username => String[1],
    cd4pe_db_password => Sensitive[String[1]],
    cd4pe_db_username => String[1],
    query_db_password => Sensitive[String[1]],
    query_db_username => String[1],
    runtime           => Cd4pe::Runtime,
    log_level         => String[1],
    max_log_size_mb   => Integer[1],
    keep_log_files    => Integer[0],
}]
