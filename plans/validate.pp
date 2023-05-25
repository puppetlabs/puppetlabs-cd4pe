# Runs all validate plans together to verify installation was successful and logs results.
# 
# @param config Cd4pe::Config configuration object, defaults to heira lookup
#
# @returns Hash aggregated pass/fail results from all checks
plan cd4pe::validate(
  Cd4pe::Config $config = cd4pe::config(),
) {
  without_default_logging() || {
    $images_result = run_plan('cd4pe::validate::images', config => $config)
    out::message(cd4pe::checks::format_results('images: verifying images are present', $images_result))

    $runtime_result = run_plan('cd4pe::validate::runtime', config => $config)
    out::message(cd4pe::checks::format_results('runtime: verifying installed runtimes match', $runtime_result))

    $database_result = run_plan('cd4pe::validate::database', config => $config)
    out::message(cd4pe::checks::format_results('database: verifying database access', $database_result))

    $results = [$images_result, $runtime_result, $database_result]
    out::message(cd4pe::checks::format_summary($results))

    $aggregated_results = cd4pe::checks::aggregate_results($results)

    if(length($aggregated_results[failed]) > 0) {
      fail_plan('One or more validation checks did not pass', 'cd4pe/error')
    }
    return $aggregated_results
  }
}
