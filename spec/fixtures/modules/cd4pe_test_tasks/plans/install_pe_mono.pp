plan cd4pe_test_tasks::install_pe_mono(
  TargetSpec $pe_host,
  String[1] $console_password = 'puppetlabs',
  String[1] $r10k_remote,
  Hash $git_settings,
  String[1] $pe_version,
  Enum['ci-ready', 's3'] $pe_source_provider,
 ) {
  $pe_conf = epp('cd4pe_test_tasks/pe.conf.epp',
    r10k_remote => $r10k_remote,
    git_settings => $git_settings,
    console_password => $console_password
  )
  $working_dir_output = run_task('enterprise_tasks::prepare', $pe_host, host => $pe_host.host)
  $working_dir = $working_dir_output.first().value()['working_dir']
  $working_path = "/tmp/${working_dir}"
  $pe_tarball_name     = "puppet-enterprise-${pe_version}-el-7-x86_64.tar.gz"

  if $pe_source_provider == 's3' {
    $pe_source = "https://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}-el-7-x86_64.tar.gz"
  }
  elsif $pe_source_provider == 'ci-ready' {
    $version_parts = split($pe_version, '-')
    $x_y_z_versions = split($version_parts[0], '[.]')
    $pe_source = "http://enterprise.delivery.puppetlabs.net/${x_y_z_versions[0]}.${x_y_z_versions[1]}/ci-ready/puppet-enterprise-${pe_version}-el-7-x86_64.tar"
  }
  #
  run_task('pe_xl::download', $pe_host,
    source => $pe_source,
    path => "${working_path}/${pe_tarball_name}",
  )
  pe_xl::file_content_upload($pe_conf, "${working_path}/pe.conf", $pe_host)
  run_task('enterprise_tasks::installer_cmd', $pe_host, host => $pe_host.host,  working_dir => $working_dir, tarball => $pe_tarball_name)
  run_task('pe_xl::mkdir_p_file', $pe_host,
    path    => '/etc/puppetlabs/puppet/autosign.conf',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0644',
    content => epp('pe_xl/autosign.conf.epp',
      lines => get_targets('ssh_nodes').map |$target| { $target.host }
    )
  )
  run_task('service', [$pe_host], action => 'stop', name => 'puppet')
  run_task('enterprise_tasks::configure_puppet_agent_service', $pe_host, host => $pe_host.host)
  run_task('enterprise_tasks::run_puppet', $pe_host)
  run_task('enterprise_tasks::run_puppet', $pe_host)
  run_task('pe_xl::rbac_token', $pe_host,
    password => $console_password
  )
  return "Successfully installed PE on target ${pe_host}"
}
