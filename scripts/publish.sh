#!/bin/bash

set -e

repository_name=$( jq -r '.admin.ecr.repository_name' <<< "${TERRAFORM_OUTPUTS}" )

aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
docker tag admin:latest ${REGISTRY_URL}/${repository_name}
docker push ${REGISTRY_URL}/${repository_name}:latest
