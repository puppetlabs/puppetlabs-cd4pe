#!/opt/puppetlabs/puppet/bin/ruby
require "json"
require "open3"
# This task runs the supplied SQL against the bitnami postgresql database container
# using the runtime provided.
# The main use case for this is to update the database configuration after a password update.

# Run SQL against the database
# Runs 3 times with a 10 second sleep between each attempt.
# @param [Hash] database_info Contains info needed to connect to the database.
# @param [String] runtime Used to execute the psql command from within the container.
# @param [String] SQL to run against the database.
# @param [String] task_dir The absolute path to the directory of the running Bolt task.
def update_database(database_info, runtime, sql, task_dir)
  psql_path = '/opt/bitnami/postgresql/bin/psql'
  combined_output = ''
  status = ''
  3.times do
    combined_output, status = Open3.capture2e("#{runtime} exec -i #{database_info['container_name']} #{psql_path} -P pager=off -U #{database_info['database_user']} -f -;", :stdin_data => sql)
    status.success? ? break : sleep(10)
  end
  {'output': combined_output, 'successful': status.success?}
end

# Pull in input
params = JSON.parse(STDIN.read)

sql_output = update_database(params['database_info'], params['runtime'], params['sql'], params['_installdir'])

# Return output to caller
output = { 'sql_output' => sql_output }
puts output.to_json
