type Cd4pe::Roles = Struct[{
    backend => Struct[{
        services => Struct[{
            pipelinesinfra => Cd4pe::Config::Pipelinesinfra,
            query          => Cd4pe::Config::Query,
        }],
        targets => Array[Target],
    }],
    database => Struct[{
        services => Struct[{
            postgres => Cd4pe::Config::Postgres,
        }],
        targets  => Array[Target],
    }],
    ui => Struct[{
        services => Struct[{
            ui => Cd4pe::Config::Teams_ui,
        }],
        targets  => Array[Target],
    }],
}]
