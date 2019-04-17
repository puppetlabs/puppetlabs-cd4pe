define cd4pe::db::app_db_env(
  String[1] $db_host,
  String[1] $db_name,
  Integer $db_port,
  String $db_prefix,
  String[1] $db_user,
  Enum['mysql', 'postgres'] $db_provider,
) {
  $app_db_env_path = "${cd4pe::db::data_root_dir}/db_env"
  $app_db_data = {
    db_host          => $db_host,
    db_port          => $db_port,
    db_prefix        => $db_prefix,
    db_provider      => $db_provider,
    db_name          => $db_name,
    db_user          => $db_user,
  }

  file { $app_db_env_path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => epp('cd4pe/app_db_env.epp', $app_db_data),
  }
}
