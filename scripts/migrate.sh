#!/bin/bash

set -euo pipefail

source ./scripts/aws_helpers.sh

migrate() {
  local migration_command="./bin/rails db:migrate"
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name="network-access-control-${ENV}-admin-cluster"
  service_name="network-access-control-${ENV}-admin-service"
  task_definition="network-access-control-${ENV}-admin-task"

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
