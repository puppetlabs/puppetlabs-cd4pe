# @api private
#
# Calls the manifests needed to install and configure the database role
#
# @param config Cd4pe::Config object with all config options
#
# @return Does not return anything
plan cd4pe::install::roles::database(
  Cd4pe::Config $config,
) {
  $apply_options = {
    '_run_as' => 'root',
    '_description' => 'install and configure application components for role: Database',
  }

  apply($config['roles']['database']['targets'], $apply_options) {
    class { 'cd4pe':
      runtime => $config['runtime'],
    }

    class { 'cd4pe::component::postgres':
      config => $config['roles']['database']['services']['postgres'],
    }
  }

  $db_role = $config['roles']['database']['services']['postgres']
  $database_info = Cd4pe::Support_bundle::Database_info.new({
      'container_name' => $db_role['container']['name'],
      'database_user'  => $db_role['admin_db_username'],
  })
  $result = run_task(
    'cd4pe::update_database_configuration',
    # For AIO, this will work. When we get to a point where we have
    # multiple database targets, we will need to select the correct one
    $config['roles']['database']['targets'][0],
    {
      'runtime' => $config['runtime'],
      'database_info' => $database_info,
      'sql' => epp('cd4pe/postgres/db_update.sql.epp',
        {
          'cd4pe_db_username' => $db_role['cd4pe_db_username'],
          'cd4pe_db_password' => "${db_role['cd4pe_db_password'].unwrap}",
          'query_db_username' => $db_role['query_db_username'],
          'query_db_password' => "${$db_role['query_db_password'].unwrap}",
        }
      ),
      '_run_as' => 'root',
      '_catch_errors' => true,
    }
  )
  if(!$result[0]['sql_output']['successful']) {
    fail_plan('Failed to update database configuration. Check postgresql logs and re-run the install plan.')
  }
}
