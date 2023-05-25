# @summary Generates a hiera data file for use when calling cd4pe::install
#
# Populates a Cd4pe::Hiera_config object with user supplied information, falling
# back to defaults if not specified. The only defaults that should be specified in
# this plan is default data that is required by the install. For instance, the secret
# key should be generated for users and saved to their config if it isn't provided. However,
# default logging config should not be written to the customer's config.
# 
# Other defaults should live in cd4pe::config()
#
# All sensitive data will be encrypted with hiera-eyaml
#
#
# @param [Sensitive[String]] admin_password Password for logging into the
#   CD4PE Admin Console
# @param [String] inventory_aio_target The target to install CD4PE on
# @param [String] resolvable_hostname The hostname users will be able to access
#   the CD4PE console at
# @param [String] admin_username The first CD4PE user of the installation. It is also sometimes referred to as the root user.
# @param [Boolean] if analytics should be enabled. Analytics are not yet implemented.
# @param [Sensitive[String]] admin_db_password Used by the admin/superuser of the Postgres instance. It's only used in setup.
# @param [Optional[String]] cd4pe_db_username Overrides the default database user which is used by the backend service.
# @param [Sensitive[String]] cd4pe_db_password Password of the database used by the backend service.
# @param [Optional[String]] query_db_username Overrides the default database user used by the query service.
# @param [Sensitive[String]] query_db_password Password of the database used by the query service.
# @param [Sensitive[String]] secret_key Used to encrypt secret data stored in the backend database.
# @param [Optional[Cd4pe::Runtime]] runtime determines which container runtime should be used for the installation.
# @param [String] hiera_config_file_path Determines where the Hiera config file is written.
# @param [String] hiera_data_file_path Determines where the CD4PE config is written.
# @param [String] pkcs7_private_key_path Path to the private key used to decrypt Hiera data encrypted with eyaml.
# @param [String] pkcs7_public_key_path Path to the public key used to encrypt Hiera data with eyaml.
plan cd4pe::generate_config(
  Sensitive[String] $admin_password,
  String $inventory_aio_target,
  String $resolvable_hostname,
  String $admin_username = 'admin',
  Boolean $analytics = true,
  Sensitive[String] $admin_db_password = Sensitive(cd4pe::secure_random(32)),
  Optional[String] $cd4pe_db_username = undef,
  Sensitive[String] $cd4pe_db_password = Sensitive(cd4pe::secure_random(32)),
  Optional[String] $query_db_username = undef,
  Sensitive[String] $query_db_password = Sensitive(cd4pe::secure_random(32)),
  Sensitive[String] $secret_key = Sensitive(cd4pe::secure_random(16)),
  Optional[Cd4pe::Runtime] $runtime = undef,
  String $hiera_config_file_path = 'hiera.yaml',
  String $hiera_data_file_path = 'data/common.yaml',
  String $pkcs7_private_key_path = 'keys/private_key.pkcs7.pem',
  String $pkcs7_public_key_path = 'keys/public_key.pkcs7.pem',
) {
  out::message('Checking if keys exist for encrypting sensitive data')
  if file::exists(file::join(cd4pe::bolt_project_dir(), $pkcs7_public_key_path)) {
    out::message('Found existing PKCS7 public key, skipping creation of new key pair')
  } else {
    out::message('Secret keys do not exist yet, creating')
    run_task('pkcs7::secret_createkeys', 'localhost', {
        public_key  => file::join(cd4pe::bolt_project_dir(), $pkcs7_public_key_path),
        private_key => file::join(cd4pe::bolt_project_dir(), $pkcs7_private_key_path)
    })
  }

  $hiera_data = {
    'cd4pe::config' => Cd4pe::Hiera_config.new({
        targets             => {
          backend  => [$inventory_aio_target],
          database => [$inventory_aio_target],
          ui       => [$inventory_aio_target],
        },
        analytics           => $analytics,
        admin_db_password   => regsubst(cd4pe::encrypt($admin_db_password, $pkcs7_public_key_path), '\n', ' ', 'MG'),
        cd4pe_db_password   => regsubst(cd4pe::encrypt($cd4pe_db_password, $pkcs7_public_key_path), '\n', ' ', 'MG'),
        cd4pe_db_username   => $cd4pe_db_username,
        query_db_password   => regsubst(cd4pe::encrypt($query_db_password, $pkcs7_public_key_path), '\n', ' ', 'MG'),
        query_db_username   => $query_db_username,
        resolvable_hostname => $resolvable_hostname,
        root_password       => regsubst(cd4pe::encrypt($admin_password, $pkcs7_public_key_path), '\n', ' ', 'MG'),
        root_username       => $admin_username,
        runtime             => $runtime,
        secret_key          => regsubst(cd4pe::encrypt($secret_key, $pkcs7_public_key_path), '\n', ' ', 'MG'),
    }),
  }

  $hiera_data_path = cd4pe::save_yaml_file($hiera_data, $hiera_data_file_path)
  out::message("Saved Hiera data file to ${hiera_data_path}")

  out::message('Checking if hiera.yaml config exists for Bolt project')
  if file::exists(file::join(cd4pe::bolt_project_dir(), $hiera_config_file_path)) {
    out::message('Found existing hiera.yaml file, skipping creation')
  } else {
    $hiera_config = {
      'version'   => 5,
      'defaults'  => {
        'datadir'   => cd4pe::file_dirname($hiera_data_file_path),
        'data_hash' => 'yaml_data',
      },
      'hierarchy' => [{
          'name'       => 'common',
          'lookup_key' => 'eyaml_lookup_key',
          'options'    => {
            'pkcs7_private_key' => $pkcs7_private_key_path,
            'pkcs7_public_key'  => $pkcs7_public_key_path,
          },
          'paths'      => [
            'common.yaml',
          ],
      }],
    }

    $hiera_config_path = cd4pe::save_yaml_file($hiera_config, $hiera_config_file_path)
    out::message("Saved Hiera config file to ${hiera_config_path}")
  }
}
