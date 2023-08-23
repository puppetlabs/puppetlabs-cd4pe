# @api private
#
# A plan to check whether the configured infra is fit for CD4PE installation and prints results. Runs all "sub" preflight plans.
#
# @param config Cd4pe::Config config object from hiera
#
# @returns Hash aggregated pass/fail results from all checks
plan cd4pe::preflight(
  Cd4pe::Config $config = cd4pe::config()
) {
  without_default_logging () || {
    $arch_result = run_plan('cd4pe::preflight::architecture', config => $config)
    out::message(cd4pe::checks::format_results('architecture: checking for supported configuration', $arch_result))

    if(length($arch_result['failed']) > 0) {
      out::message(cd4pe::checks::format_summary([$arch_result]))
      fail_plan($arch_result['failed'][0], 'cd4pe/error')
    }

    $targets = $config['all_targets']

    $runtime_conflict_result = run_plan('cd4pe::preflight::runtime::conflict', config => $config)
    out::message(cd4pe::checks::format_results('runtime: checking for installed container runtimes', $runtime_conflict_result))

    apply_prep($targets, { '_run_as' => 'root' })

    $memory_result = run_plan('cd4pe::preflight::memorycheck', config => $config)
    out::message(cd4pe::checks::format_results('memory: checking for required 7.45 GiB', $memory_result))

    $os_result = run_plan('cd4pe::preflight::oscheck', config => $config)
    out::message(cd4pe::checks::format_results('os: checking for supported operating system', $os_result))

    $processor_result = run_plan('cd4pe::preflight::processorcheck', config => $config)
    out::message(cd4pe::checks::format_results('processors: checking for required 4 CPUs', $processor_result))

    $results = [$arch_result, $runtime_conflict_result, $memory_result, $os_result, $processor_result]
    out::message(cd4pe::checks::format_summary($results))

    $aggregated_results = cd4pe::checks::aggregate_results($results)

    if(length($aggregated_results[failed]) > 0) {
      fail_plan('One or more preflight checks did not pass', 'cd4pe/error')
    }
  }
}
