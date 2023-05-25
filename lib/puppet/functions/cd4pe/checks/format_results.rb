# Formats check results for display in the console
Puppet::Functions.create_function(:'cd4pe::checks::format_results') do
    # Formats check results for display in the console
    # @param [String] header the text displayed at the top of the section in white text
    # @param [Hash] result hash containing the check results to display
    # @returns [String] gorgeous formatted output, complete with colors
    dispatch :format_results do
        param 'String', :header
        param 'Hash', :results
        return_type 'String'
    end

    def format_results(header, results)
        message = "#{header}\n"
        message += format_passed(results['passed'])
        message += format_failed(results['failed'])
        message += "\n"
    end

    def format_passed(passed)
        message = ""
        if(passed.length > 0)
            message += format_checks(passed, green_passed())
        end
        message
    end

    def format_failed(failed)
        message = ""
        if(failed.length > 0)
            message += format_checks(failed, red_failed())
        end
        message
    end

    def format_checks(section, prefix)
        formatted_section = ""
        section.each do |item|
            formatted_section += "  #{prefix} #{item}#{end_color}\n"
        end
        formatted_section
    end

    def green_passed()
        "\e[32m\u2713 [PASSED]"
    end

    def red_failed()
        "\e[31m\u2715 [FAILED]"
    end

    def end_color()
        "\e[0m"
    end

    def print_number_of_checks(number)
        "#{number} #{pluralize_check(number)}"
    end

    def pluralize_check(number)
        number == 1 ? 'check' : 'checks'
    end
end