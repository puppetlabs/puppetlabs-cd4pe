# Creates summary for the end of check output
Puppet::Functions.create_function(:'cd4pe::checks::format_summary') do
    # Creates summary for the end of check output
    # @param [Array] results list of results hashes that need to be summarized
    # @returns [String] gorgeous formatted output, complete with colors
    dispatch :format_summary do
        param 'Array', :results
        return_type 'String'
    end

    def format_summary(results)
        message = ""
        total_results_count = results.length
        failed_results_list = extract_failed_results(results)

        if(failed_results_list.length > 0) 
            message += summary_message(total_results_count, failed_results_list.length)
            failed_results_list.each do |result|
                message += failures_per_result(result)
            end
        else
            message += summary_message(total_results_count, 0)
        end
        message
    end

    def red(message)
        "\e[31m#{message}\e[0m"
    end

    def pluralize_check(number)
        number == 1 ? 'check' : 'checks'
    end

    def extract_failed_results(results)
        results.filter{ |result| result['failed'].length > 0 }
    end

    def failures_per_result(failed_result)
        failed_result['failed'].map { |failure| " . #{red(failure)}\n"}.join
    end

    def summary_message(total_count, failed_count)
        if(failed_count > 0)
            "#{total_count} #{pluralize_check(total_count)} completed, #{failed_count} failed.\n"
        else
            "#{total_count} #{pluralize_check(total_count)} completed.\n"
        end
    end
end