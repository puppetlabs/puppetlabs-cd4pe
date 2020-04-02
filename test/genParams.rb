#!/usr/bin/env ruby

require 'json'
require 'set'

usage = "
Usage => genParams.rb <storageType> <enableSSL> <ssl_endpoint> <workspace_root> <provider>
  where <storageType> is one of
  'disk' or 'artifactory'

  <enableSSL> is 'enabled' and requires
  <ssl_endpoint> to be set to a valid FQDN
  <workspace_root> is the root name for adding a user/workspace pair
  <provider> is one of
  'none', gitlab', 'GHE', 'bbs', ...
"

unless ARGV.length == 5
  abort(usage)
end

object_storage_type = ARGV[0]
ssl_enabled = ARGV[1] == 'enabled'
ssl_endpoint = ARGV[2]
workspace_root = ARGV[3]
provider = ARGV[4]

# keys needed for root_config
base_params = {
  'root_email'             => 'noreply@puppet.com',
  'root_password'          => 'puppetlabs',
  'generate_trial_license' => true,
}

# for S3 access
s3_constants = {
  'storage_provider' => 'S3',
}

storage_s3 = {
  'storage_bucket'   => '.storage.S3.s3BucketName',
  'storage_endpoint' => '.storage.S3.s3Endpoint',
  's3_access_key'    => '.storage.S3.awsAccessKey',
  's3_secret_key'    => '.storage.S3.secretKey',
}

# for Artifactory access
artifactory_constants = {
  'storage_provider' => 'ARTIFACTORY',
}

storage_artifactory = {
  'storage_bucket'           => '.storage.Artifactory.artifactoryGenericBinaryRepositoryName',
  'storage_endpoint'         => '.storage.Artifactory.artifactoryEndpoint',
  'artifactory_access_token' => '.storage.Artifactory.artifactoryAccessToken',
}

# for SSL
ssl_constants = {
  'ssl_enabled' => ssl_enabled,
  'ssl_endpoint' => ssl_endpoint,
}

ssl_keys = {
  'ssl_server_certificate'    => '.ssl.serverCertificate',
  'ssl_authority_certificate' => '.ssl.authorityCertificate',
  'ssl_server_private_key'    => '.ssl.serverPrivateKey',
}

derived_email = "#{workspace_root}@example.com"
derived_username = "#{workspace_root}"
derived_workspace = "#{workspace_root}_ws"

# keys needed for create_user
user_params = {
  'user_config' => {
    'email'      => derived_email,
    'username'   => derived_username,
    'password'   => 'puppetlabs',
    'first_name' => workspace_root,
    'last_name'  => 'Smith',
  },
}

# keys needed for create_workspace
workspace_params = {
  'workspace_config' => {
    'email'     => derived_email,
    'password'  => 'puppetlabs',
    'username'  => derived_username,
    'workspace' => derived_workspace,
  },
}

# keys needed for adding vcs integration
vcs_constants = {
  'email'     => derived_email,
  'password'  => 'puppetlabs',
  'provider'  => provider,
  'workspace' => derived_workspace,
}

# for gitlab
vcs_gitlab = {
  'host'  => '.integrations.Gitlab.host',
  'token' => '.integrations.Gitlab.token',
}

# for GHE
vcs_GHE = {
  'host'          => '.integrations.GithubEnterprise.host',
  'token'         => '.integrations.GithubEnterprise.token',
  'caCertificate' => {
    'certificate' => '.integrations.GithubEnterprise.caCertificate',
  }
}

# for bbs
vcs_bbs = {
  'host'     => '.integrations.BitbucketServer.bitbucketServerHost',
  'username' => '.integrations.BitbucketServer.username',
  'password' => '.integrations.BitbucketServer.password',
  'sshPort'  => '.integrations.BitbucketServer.sshPort',
}

def extract_key_values(_json_blob, the_keys)
  the_keys.each do |key, value|
    the_keys[key] = value.respond_to?(:to_hash) ?
      extract_key_values(_json_blob, value) :
      eval('_json_blob' + value) # rubocop:disable Security/Eval
  end
end

# main
#

raw_json = JSON.parse(File.read("#{Dir.home}/.cdpe-workflow-tests-config.json"),
                      object_class: OpenStruct)

# storage type
case object_storage_type
when 'disk'
  storage_params = {}
#
# disabling until we determine how make s3 access frictionless
#
# when 's3'
#   storage_params = extract_key_values(raw_json, storage_s3)
#   storage_params = [*s3_constants, *storage_params].to_h
#
when 'artifactory'
  storage_params = extract_key_values(raw_json, storage_artifactory)
  storage_params = [*artifactory_constants, *storage_params].to_h
else
  abort("Unrecognized storage type '#{object_storage_type}' specified")
end

# enable SSL
if ssl_enabled
  ssl_params = extract_key_values(raw_json, ssl_keys)
  ssl_params = [*ssl_constants, *ssl_params].to_h
else
  ssl_params = {}
end

root_config_params = { 'root_config' => [*base_params, *storage_params, *ssl_params].to_h }

# vcs provider
vcs_providers = ['gitlab','GHE','bbs']

if provider == 'none'
  vcs_params = { 'vcs_config' => {} }
elsif vcs_providers.include?(provider)
  vcs_params = extract_key_values(raw_json, eval('vcs_' + provider)) # rubocop:disable Security/Eval
  vcs_params = { 'provider_specific' => vcs_params }
else
  abort("Unrecognized vcs provider '#{provider}' specified")
end

vcs_params = { 'vcs_config' => [*vcs_constants, *vcs_params].to_h } unless provider == 'none'

full_set = [*root_config_params, *user_params, *workspace_params, *vcs_params].to_h

File.open('params.json', 'w') do |f|
  f.write(JSON.pretty_generate(full_set))
end
