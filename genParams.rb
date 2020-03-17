#!/usr/bin/env ruby

require 'json'

usage = "
Usage: genParams.rb <storageType> <enableSSL> <ssl_endpoint>
  where <storageType> is one of
  'disk', 's3', or 'artifactory'

  <enableSSL> is 'enabled' and requires
  <ssl_endpoint> to be set to a valid FQDN
"

unless ARGV.length == 3
  abort(usage)
end

object_storage_type = ARGV[0]
ssl_enabled = ARGV[1] == 'enabled'
ssl_endpoint = ARGV[2]

# keys needed everywhere
base_params = {
  'root_email'             => 'noreply@puppet.com',
  'root_password'          => 'puppetlabs',
  'generate_trial_license' => true,
}

# keys needed for S3 access
s3_constants = {
  'storage_provider' => 'S3',
}

storage_s3 = {
  'storage_bucket'   => '.storage.S3.s3BucketName',
  'storage_endpoint' => '.storage.S3.s3Endpoint',
  's3_access_key'    => '.storage.S3.awsAccessKey',
  's3_secret_key'    => '.storage.S3.secretKey',
}

# keys needed for Artifactory access
artifactory_constants = {
  'storage_provider' => 'ARTIFACTORY',
}

storage_artifactory = {
  'storage_bucket'           => '.storage.Artifactory.artifactoryGenericBinaryRepositoryName',
  'storage_endpoint'         => '.storage.Artifactory.artifactoryEndpoint',
  'artifactory_access_token' => '.storage.Artifactory.artifactoryAccessToken',
}

# keys needed for SSL
ssl_constants = {
  'ssl_enabled' => ssl_enabled,
  'ssl_endpoint' => ssl_endpoint,
}

ssl_keys = {
  'ssl_server_certificate'    => '.ssl.serverCertificate',
  'ssl_authority_certificate' => '.ssl.authorityCertificate',
  'ssl_server_private_key'    => '.ssl.serverPrivateKey',
}

def extract_key_values(_json_blob, the_keys)
  the_keys.each do |key, value|
    the_keys[key] = eval('_json_blob' + value) # rubocop:disable Security/Eval
  end
end

# main
#

# TODO: check exit status from x%(); parameterize secret object being fetched?
raw_json = JSON.parse(`op get item cdpe-workflow-tests-config.json | jq -r '.details.notesPlain'`.delete('`'), object_class: OpenStruct)

## storage type
case object_storage_type
when 'disk'
  storage_params = {}
when 's3'
  storage_params = extract_key_values(raw_json, storage_s3)
  storage_params = [*s3_constants, *storage_params].to_h
when 'artifactory'
  storage_params = extract_key_values(raw_json, storage_artifactory)
  storage_params = [*artifactory_constants, *storage_params].to_h
else
  abort("Unrecognized storage type '#{object_storage_type}' specified")
end

## enable SSL
if ssl_enabled
  ssl_params = extract_key_values(raw_json, ssl_keys)
  ssl_params = [*ssl_constants, *ssl_params].to_h
else
  ssl_params = {}
end

bolt_key_set = [*base_params, *storage_params, *ssl_params].to_h

File.open('params.json', 'w') do |f|
  f.write(JSON.pretty_generate(bolt_key_set))
end
