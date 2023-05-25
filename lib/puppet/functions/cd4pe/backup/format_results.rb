# Formats backup_list results for display in the console
# Also adds an age column to the output
require 'date'
Puppet::Functions.create_function(:'cd4pe::backup::format_results') do
    # Formats backup_list results for display in the console
    # @param [Array] result array containing the backup_list results to display
    # @returns [String] formatted output
    dispatch :format_results do
        param 'Array', :results
        return_type 'String'
    end

    def format_results(results)
        str_format = "%-41s %-9s %-10s %-5s\n"
        message = str_format % ["NAME", "VERSION", "SIZE", "AGE"]
        results.each do |result|
          age = (Time.now.utc.to_date - Date.parse(result['name'][/(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})/,1])).to_i
          name = File.basename(result['name'])
          message += str_format % [name, result['version'], result['size'], "#{age}d"]
        end
        message += "\n"
    end
end
