#!/usr/bin/env bash

ssh_key=${SSH_KEY:-id_rsa}

test_image=artifactory.delivery.puppetlabs.net/cd4pe-config-test-vm:latest

docker pull $test_image

docker run -ti --rm \
       --volume "$PWD"/..:/app \
       --volume "$HOME"/.ssh:/root/.ssh \
       --env SSH_KEY="$ssh_key" \
       --env CD4PE_IMAGE="$CD4PE_IMAGE" \
       --env CD4PE_VERSION="$CD4PE_VERSION" \
       $test_image \
       /app/test/doConfigTestVm.sh "$@"
