# @api private
#
# Validates we can log into the database on the database target
# as the cd4pe and query users with their passwords over TCP
#
# @param config Cd4pe::Config object with all config options
#
# @return Hash returns pass/fail results from check
plan cd4pe::validate::database (
  Cd4pe::Config $config = cd4pe::config(),
) {
  $runtime = $config['runtime']
  # TODO: When we add support for multiple database targets, we'll need to run against the right one
  $target = $config['roles']['database']['targets'][0]

  $sql_command = '\d'
  # Can the cd4pe user be accessed over TCP using the password
  $cd4pe_password = $config['roles']['database']['services']['postgres']['cd4pe_db_password']
  $cd4pe_subcommand = "PGPASSWORD=${cd4pe_password.unwrap} psql postgresql://postgres:5432/cd4pe?sslmode=disable -U cd4pe -c \\\"${sql_command}\\\""
  $cd4pe_command = "${runtime} exec postgres bash -c \"${cd4pe_subcommand}\""
  $cd4pe_connect_results = run_command(
    $cd4pe_command,
    $target,
    { '_run_as' => 'root', '_catch_errors' => true, },
  )

  # Can the query user be accessed over TCP using the password
  $query_password = $config['roles']['database']['services']['postgres']['query_db_password']
  $query_subcommand = "PGPASSWORD=${query_password.unwrap} psql postgresql://postgres:5432/query?sslmode=disable -U query -c \\\"${sql_command}\\\""
  $query_command = "${runtime} exec postgres bash -c \"${query_subcommand}\""
  $query_connect_results = run_command(
    $query_command,
    $target,
    { '_run_as' => 'root', '_catch_errors' => true, },
  )

  $results = [$cd4pe_connect_results, $query_connect_results].reduce({ 'failed' => [], 'passed' => [] }) |$memo, $connect_results| {
    if($connect_results[0].ok) {
      $passed_targets = ["${target.name} : Database connections successful"] + $memo['passed']
      $failed_targets = $memo['failed']
    } else {
      $passed_targets = $memo['passed']
      $failed_targets = ["${target.name} : ${connect_results[0].value['merged_output']}"] + $memo['failed']
    }

    $memo + { 'passed' => $passed_targets.unique, 'failed' => $failed_targets.unique }
  }

  return $results
}
