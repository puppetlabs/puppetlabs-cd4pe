#!/usr/bin/env bash
set -e

install_module() {
  # TODO: check for param?
  local __result=${1}
  local tmpdir=$(mktemp -d)
  mkdir -p ${tmpdir}/Boltdir
  cat <<! >${tmpdir}/Boltdir/Puppetfile
# forge
# mod 'puppetlabs-cd4pe', '1.4.1'

# git
mod 'puppetlabs-cd4pe', git: 'git@github.com:puppetlabs/puppetlabs-cd4pe.git', ref: 'master'
!
  (cd ${tmpdir}; bolt --modulepath . puppetfile install)
  eval ${__result}="'$tmpdir'"
}

waitUntilCd4peUp() {
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

function poStatusCheck() {
  poStatus=$(op confirm --all 2>&1)
  if [ ! $? == 0 ]; then
    echo "Issue with 'op' utility. Have you started a session?"
    echo
    echo "${poStatus}"
    exit 1
  fi
}

# main
#

CD4PE_IMAGE=${CD4PE_IMAGE:-artifactory.delivery.puppetlabs.net/cd4pe-dev}
[ -z "${CD4PE_VERSION}" ] && { echo "Please export CD4PE_VERSION to the desired version on Artifactory"; exit 1; }

## most parameters are qualified by the genParams.rb script, not in here
## derived from https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
##
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -o|--object-store)
      objectStorageType=$2
      shift 2
      ;;
    -s|--ssl)
      sslEnabled="enabled"
      shift
      ;;
    -p|--no-po-check)
      skipPoCheck="true"
      shift
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
  [ -z "${skipPoCheck}" ] && poStatusCheck
set -e

install_module moduledir

# TODO: make cleanup an option?
rm -f inventory.yaml
bundle exec rake "test:install:cd4pe:module[${CD4PE_IMAGE},${CD4PE_VERSION}]"

target=$(yaml2json inventory.yaml | jq -r '.groups[1].targets[0].uri')
waitUntilCd4peUp ${target}

./genParams.rb ${objectStorageType:-disk} ${sslEnabled:-disabled} ${target}

bolt task run --targets all --modulepath ${moduledir} --inventoryfile inventory.yaml cd4pe::root_configuration --params @params.json

# TODO: make cleanup an option?
rm -f params.json