# Aggregates check results (validate, preflight, or other)
Puppet::Functions.create_function(:'cd4pe::checks::aggregate_results') do
    # Aggregates check results (validate, preflight, or other)
    # @param [Array] results array of check results from various check plans
    # @returns [Hash] aggregated results
    dispatch :aggregate_results do
        param 'Array', :results
        return_type 'Hash'
    end

    def aggregate_results(results)
        aggregated = { 'passed' => [], 'failed' => []}
        results.each do |result|
            aggregated['passed'].concat(result['passed'])
            aggregated['failed'].concat(result['failed'])
        end
        aggregated
    end
end