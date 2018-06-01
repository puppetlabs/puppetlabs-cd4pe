class cd4pe (
  String  $mysql_host,
  String  $mysql_db,
  Integer $mysql_port,
  String  $mysql_user,
  String  $mysql_pass,
  String  $dump_uri,
  String  $pfi_secret_key,
  String  $version = "latest",
) {
  include docker

  $db_endpoint = "mysql:://${$mysql_host}:${mysql_port}/${mysql_db}"

  docker::image { 'puppet/continuous-delivery-for-puppet-enterprise':
    image_tag => $version,
  }

  docker::run { 'cd4pe':
    image   => 'puppet/continuous-delivery-for-puppet-enterprise',
    volumes => [
      "/var/lib/mysql",
    ],
    ports   => [
      "8080:8080",
      "8000:8000",
      "7000:7000",
    ],
    env     => [
      "DB_ENDPOINT=${db_endpoint}",
      "DB_USER=${myql_user}",
      "DB_PASS=${mysql_pass}",
      "DUMP_URI=${$dump_uri}",
      "PFI_SECRET_KEY=${pfi_secret_key}",
    ]
  }
}
