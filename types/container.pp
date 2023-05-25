type Cd4pe::Container = Struct[{
    name             => String[1],
    image            => String[1],
    log_volume_name  => String[1],
    extra_parameters => Optional[String[1]],
}]
