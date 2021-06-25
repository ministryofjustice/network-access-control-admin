#!/bin/bash

set -euo pipefail

source ./scripts/aws_helpers.sh

migrate() {
  local migration_command="./bin/rails db:migrate"
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
    "${migration_command}"
}

main() {
  assume_deploy_role
  migrate
}

main
