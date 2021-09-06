#!/bin/bash

set -v -e -u -o pipefail

source ./scripts/aws_helpers.sh

require_ssl() {
  local require_ssl_command="mysql -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} --ssl-ca=../cert/rds-combined-ca-bundle.pem -e \"ALTER USER '${DB_USER}'@'%' REQUIRE SSL;\""
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
    "${require_ssl_command}"
}

save_db() {
  mysqldump -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} --ssl-ca=../cert/rds-combined-ca-bundle.pem >> ./data.sql
  aws s3 cp ./data.sql s3://${RADIUS_CONFIG_BUCKET_NAME}
}

main() {
  save_db
  assume_deploy_role
  require_ssl
}

main
