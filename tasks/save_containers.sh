#!/bin/bash
docker pull gcr.io/platform-services-297419/cd4pe/continuous-delivery-for-puppet-enterprise:4.15.1 1>&2
docker pull gcr.io/platform-services-297419/teams-ui:1.13.0 1>&2
docker pull gcr.io/estate-reporting/query-service:1.8.5 1>&2

TARGET_DIR=$(mktemp -d -t cd4pe-containers-XXXXXXXXXX)
docker save \
gcr.io/platform-services-297419/cd4pe/continuous-delivery-for-puppet-enterprise:4.15.1 \
gcr.io/platform-services-297419/teams-ui:1.13.0 \
gcr.io/estate-reporting/query-service:1.8.5 | gzip > $TARGET_DIR/containers.tar.gz
JSON='{"containers_file": "'"$TARGET_DIR/containers.tar.gz"'"}'
printf '%s' "$JSON"