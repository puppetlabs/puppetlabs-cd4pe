plan cd4pe_test_tasks::setup_test_environment(
  Enum['scale', 'acceptance'] $environment_type,
  Enum['installer_task', 'module'] $cd4pe_install_type,
  Enum['ci-ready', 's3'] $pe_source_provider,
  String[1] $pe_version,
  String[1] $cd4pe_image = 'pcr-internal.puppet.net/pipelines/pfi',
  String[1] $cd4pe_version = 'latest',
) {
  # Is there a way to just get all tagets?
  $target = get_targets('ssh_nodes')
  $pe_host = $target[0]
  $console_password = 'puppetlabs'
  if $environment_type == 'acceptance' {
    $r10k_private_key = '/etc/puppetlabs/r10k-github'
    $module_private_key = '/etc/puppetlabs/r10k-cd4pe-module'
    run_plan('cd4pe_test_tasks::install_pe_mono',
      console_password => $console_password,
      pe_host => $pe_host,
      pe_version =>  $pe_version,
      pe_source_provider => $pe_source_provider,
      r10k_remote => 'git@github.com:puppetlabs/cd4pe-acceptance-control-repo.git',
      git_settings => {
        'private-key' => $r10k_private_key,
        'repositories' => [
          {
             'remote' => 'git@github.com:puppetlabs/puppetlabs-cd4pe.git',
             'private-key' => $module_private_key,
          }
        ]
      }
    )

    #TODO: Reference project root in a better way
    $pwd = system::env('PWD')
    $secrets_path = "${pwd}/spec/fixtures/secrets"
    upload_file("${secrets_path}/cd4pe-acceptance-control-repo", $r10k_private_key, $pe_host)
    upload_file("${secrets_path}/cd4pe-acceptance-module", $module_private_key, $pe_host)
    run_command("chown pe-puppet:pe-puppet ${r10k_private_key}", $pe_host, _catch_errors => true)
    run_command("chown pe-puppet:pe-puppet ${module_private_key}", $pe_host, _catch_errors => true)

    # Set up the CD4PE host
    $cd4pe_host = $target[1]
    run_task('pe_xl::agent_install', $cd4pe_host,
      server => $pe_host.host,
      install_flags => [],
      _catch_errors => true,
      )
    run_task('pe_xl::puppet_runonce', $cd4pe_host, _catch_errors => true)
    #TODO: Encapsulate all the CD4PE setup in a plan
    $cd4pe_install_task_params = "master_host='${pe_host.host}' cd4pe_admin_email='admin@example.com' cd4pe_admin_password='puppetlabs' cd4pe_image='${cd4pe_image}' cd4pe_version='${cd4pe_version}'"
    run_command("puppet task run pe_installer_cd4pe::install --nodes ${cd4pe_host.host} ${cd4pe_install_task_params}", $pe_host)

  } else {
    return "The 'scale' test environment has not been implemented yet."
  }
}
