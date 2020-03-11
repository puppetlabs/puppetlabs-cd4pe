#!/usr/bin/env ruby

require 'json'

usage = %q(
Usage: genParams.rb <storageType> <enableSSL> <sslEndpoint>
  where <storageType> is one of
  'disk', 's3', or 'artifactory'

  <enableSSL> is 'enabled' and requires
  <sslEndpoint> to be set to a valid FQDN
)

unless ARGV.length == 3
  abort(usage)
end

objectStorageType = ARGV[0]
sslEnabled = ARGV[1] == 'enabled'
sslEndpoint = ARGV[2]

# keys needed everywhere
baseParams = {
  "root_email"             => "noreply@puppet.com",
  "root_password"          => "puppetlabs",
  "generate_trial_license" => true
}

# keys needed for S3 access
s3Constants = {
  "storage_provider" => "S3"
}

storageS3 = {
  "storage_bucket"   => ".storage.S3.s3BucketName",
  "storage_endpoint" => ".storage.S3.s3Endpoint",
  "s3_access_key"    => ".storage.S3.awsAccessKey",
  "s3_secret_key"    => ".storage.S3.secretKey"
}

# keys needed for Artifactory access
artifactoryConstants = {
  "storage_provider" => "ARTIFACTORY"
}

storageArtifactory = {
  "storage_bucket"           => ".storage.Artifactory.artifactoryGenericBinaryRepositoryName",
  "storage_endpoint"         => ".storage.Artifactory.artifactoryEndpoint",
  "artifactory_access_token" => ".storage.Artifactory.artifactoryAccessToken"
}

# keys needed for SSL
sslConstants = {
  "ssl_enabled" => sslEnabled,
  "ssl_endpoint" => sslEndpoint
}

sslKeys = {
  "ssl_server_certificate"    => ".ssl.serverCertificate",
  "ssl_authority_certificate" => ".ssl.authorityCertificate",
  "ssl_server_private_key"    => ".ssl.serverPrivateKey",
}

def extractKeyValues(jsonBlob, theKeys)
  theKeys.each do |key, value|
    theKeys[key] = eval("jsonBlob" + value)
  end
end

# main
#

# TODO: check exit status from x%(); parameterize secret object being fetched?
rawJson = JSON.parse( %x( op get item cdpe-workflow-tests-config.json | jq -r '.details.notesPlain' ).delete('`'), object_class: OpenStruct)

## storage type
case objectStorageType
when 'disk'
  storageParams = {}
when 's3'
  storageParams = extractKeyValues(rawJson, storageS3)
  storageParams = [*s3Constants, *storageParams].to_h
when 'artifactory'
  storageParams = extractKeyValues(rawJson, storageArtifactory)
  storageParams = [*artifactoryConstants, *storageParams].to_h
else
  abort("Unrecognized storage type '#{objectStorageType}' specified")
end

## enable SSL
if sslEnabled
  sslParams = extractKeyValues(rawJson, sslKeys)
  sslParams = [*sslConstants, *sslParams].to_h
else
  sslParams = {}
end

boltKeySet = [*baseParams, *storageParams, *sslParams].to_h

File.open("params.json", "w") do |f|
  f.write(JSON.pretty_generate(boltKeySet))
end