require 'json'

step 'Copy module to master VM' do
  metadata = JSON.parse(File.read('metadata.json'))
  module_tarball = "#{metadata['name']}-#{metadata['version']}.tar.gz"

  # We use this instead of `copy_module_to` from beaker-puppet as the
  # Rakefile contains logic for building a tarball that contains an
  # assembled JAR.
  master.do_scp_to("pkg/#{module_tarball}", "/tmp/#{module_tarball}", {})
  # The uninstall is here to ensure we load in a fresh copy of the
  # module if the tests are being re-run.
  on(master, puppet('module', 'uninstall', 'puppetlabs-catalog_diff_api'),
             accept_all_exit_codes: true)
  on(master, puppet('module', 'install', "/tmp/#{module_tarball}"))
end

step 'Install module on master VM' do
  expect_service_mounted = if master[:type].start_with?('foss') || master[:pe_ver].start_with?('2018.1')
                             true
                           else
                             false
                           end

  manifest = <<-EOM
if fact('pe_server_version') =~ String {
  # Pulls in other PE config bits that puppetserver_diff_api::server hooks into.
  include puppet_enterprise::profile::certificate_authority
} else {
  service{'puppetserver': ensure => running}
}

class{'catalog_diff_api::server': }
EOM

  apply_manifest_on(master, manifest)

  status_check = "curl -k https://localhost:8140/status/v1/services"
  response = JSON.parse(on(master, status_check).stdout.chomp)

  if expect_service_mounted
    refute_nil(response['catalog-diff-api-service'])
  else
    assert_nil(response['catalog-diff-api-service'])
  end
end
