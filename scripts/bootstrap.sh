#!/bin/bash

set -v -e -u -o pipefail

source ./scripts/aws_helpers.sh

require_ssl() {
  local require_ssl_command="mysql -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} --ssl-ca=../cert/rds-combined-ca-bundle.pem -e \"ALTER USER '${DB_USER}'@'%' REQUIRE SSL;\""
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name="network-access-control-${ENV}-admin-cluster"
  service_name="network-access-control-${ENV}-admin"
  task_definition="network-access-control-${ENV}-admin-task"

  echo "${cluster_name}"
  echo "${service_name}"
  aws sts get-caller-identity
  echo "===================================================================================================="

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${require_ssl_command}"
}

main() {
  assume_deploy_role
  require_ssl
}

main
