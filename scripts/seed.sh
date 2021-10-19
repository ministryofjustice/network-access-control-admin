#!/bin/bash

set -euo pipefail

source ./scripts/aws_helpers.sh

seed() {
  local seed_command="./bin/rails db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1 db:seed"
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name=$( jq -r '.admin.ecs.cluster_name' <<< "${TERRAFORM_OUTPUTS}" )
  service_name=$( jq -r '.admin.ecs.service_name' <<< "${TERRAFORM_OUTPUTS}" )
  task_definition=$( jq -r '.admin.ecs.task_definition_name' <<< "${TERRAFORM_OUTPUTS}" )

  aws sts get-caller-identity

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${seed_command}"
}

main() {
  if [ "$ENV" == "development" ]; then
    assume_deploy_role
    seed
  fi
}

main
