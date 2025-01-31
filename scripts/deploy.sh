#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks

set -euo pipefail

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-radius-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

deploy() {
  cluster=$1
  service=$2

  aws ecs update-service --cluster "$cluster" --service "$service" --force-new-deployment

  # Wait for the ECS service to stabilize (reach steady state)
  echo "Waiting for ECS service $service to reach steady state..."
  aws ecs wait services-stable --cluster "$cluster" --services "$service"
  
  if [ $? -eq 0 ]; then
    echo "ECS service $service has reached steady state."
  else
    echo "ECS service $service failed to reach steady state."
    exit 1
  fi
}

main

# Wait for the ECS service to reach a steady state
echo "Waiting for ECS service to reach a steady state..." 
aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME 

# Check if the ECS service reached a steady state 
if [ $? -eq 0 ]; then 
  echo "ECS service has reached a steady state." 
  exit 0 
else 
  echo "Failed to reach steady state for ECS service." 
  exit 1 
fi