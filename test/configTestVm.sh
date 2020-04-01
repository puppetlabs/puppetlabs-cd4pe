#!/usr/bin/env bash
set -e

function usage() {
  echo "No arguments are required. By default, create a VM using the disk object-store,"
  echo "not enable SSL and create a default user & workspace. To modify this behaviour,"
  echo "use the following switches (default values):"
  echo
  echo "  -o|--object-store disk|artifactory|s3   specify the object-store (${objectStorageType})"
  echo "  -s|--ssl                                configure SSL (${sslEnabled})"
  echo "  -p|--no-op-check                        disable the 1Password op tool sanity check (enabled)"
  echo "  -b|--base <base>                        specify base name of workspace, email & username (${baseName})"
  echo "  -v|--vcs-provider <vcs>                 specify the VCS provider (${vcsProvider})"
}

function waitUntilCd4peUp() {
  attempt_counter=0
  max_attempts=60
  echo "Waiting up to 5 minutes for CD4PE to come up"

  until $(curl --output /dev/null --silent --head --fail http://${1}:8080); do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo
      echo "Max attempts reached"
      exit 1
    fi

    echo -n '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 5
  done
  echo
}

# derived from https://medium.com/@frontman/how-to-parse-yaml-string-via-command-line-374567512303
function yaml2json() {
  ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

function opStatusCheck() {
  opStatus=$(op confirm --all 2>&1)
  if [ ! $? == 0 ]; then
    echo "Issue with 'op' utility. Have you started a session?"
    echo
    echo "${opStatus}"
    exit 1
  fi
}

# main
#

CD4PE_IMAGE=${CD4PE_IMAGE:-artifactory.delivery.puppetlabs.net/cd4pe-dev}
[ -z "${CD4PE_VERSION}" ] && { echo "Please export CD4PE_VERSION to the desired version on Artifactory"; exit 1; }

objectStorageType="disk"
sslEnabled="disabled"
baseName="otto"
vcsProvider="none"

## most parameters are qualified by the genParams.rb script, not in here
## derived from https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
##
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -o|--object-store)
      objectStorageType="$2"
      shift 2
      ;;
    -s|--ssl)
      sslEnabled="enabled"
      shift
      ;;
    -p|--no-op-check)
      skipPoCheck="true"
      shift
      ;;
    -b|--base)
      baseName="$2"
      shift 2
      ;;
    -v|--vcs-provider)
      vcsProvider="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments
eval set -- "$PARAMS"

set +e
  [ -z "${skipPoCheck}" ] && opStatusCheck
set -e

moduledir='..'

rm -f ../inventory.yaml
bundle exec rake "test:install:cd4pe:module[${CD4PE_IMAGE},${CD4PE_VERSION}]"

target=$(yaml2json ../inventory.yaml | jq -r '.groups[1].targets[0].uri')
waitUntilCd4peUp ${target}

./genParams.rb ${objectStorageType} ${sslEnabled} ${target} ${baseName} ${vcsProvider}

bolt plan run --targets all --modulepath ${moduledir}/spec/fixtures/modules:${moduledir} --inventoryfile ../inventory.yaml cd4pe_test_tasks::configure_test_vm --params @params.json

rm -f params.json

echo
echo "Your VM is available at http://${target}:8080 with a login of ${baseName:-otto}@example.com and the usual password :)"