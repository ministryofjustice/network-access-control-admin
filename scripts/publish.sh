#!/bin/bash

set -e

repository_url=$( jq -r '.admin.ecr.repository_url' <<< "${TERRAFORM_OUTPUTS}" )

aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
docker tag admin:latest ${repository_url}
docker push ${repository_url}:latest
