export PARAM=$(aws ssm get-parameters --region eu-west-2 --with-decryption --names \
"/moj-network-access-control/$ENV/admin_db_username" \
"/moj-network-access-control/$ENV/admin_db_password" \
"/moj-network-access-control/$ENV/admin/db/hostname" \
"/moj-network-access-control/$ENV/admin/db/name" \
"/moj-network-access-control/$ENV/admin/ecr/endpoint" \
"/moj-network-access-control/$ENV/admin/rails_master_key" \
"/moj-network-access-control/terraform/$ENV/outputs" \
"/codebuild/$ENV/account_id" \
"/codebuild/pttp-ci-infrastructure-core-pipeline/${ENV}/assume_role" \
"/moj-network-access-control/$ENV/cloudwatch_link" \
    --query Parameters)

export PARAM2=$(aws ssm get-parameters --region eu-west-2 --with-decryption --names \
    "/moj-network-access-control/docker/username" \
    "/moj-network-access-control/docker/password" \
    --query Parameters)


declare -A parameters


parameters["DB_USER"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin_db_username")) | .Value' --raw-output)"
parameters["DB_PASS"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin_db_password")) | .Value' --raw-output)"
parameters["DB_HOST"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin/db/hostname")) | .Value' --raw-output)"
parameters["DB_NAME"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin/db/name")) | .Value' --raw-output)"
parameters["REGISTRY_URL"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin/ecr/endpoint")) | .Value' --raw-output)"
parameters["SECRET_KEY_BASE"]="$(echo $PARAM | jq '.[] | select(.Name | test("admin/rails_master_key")) | .Value' --raw-output)"
parameters["TERRAFORM_OUTPUTS"]="$(echo $PARAM | jq '.[] | select(.Name | test("outputs")) | .Value' --raw-output)"
parameters["TARGET_AWS_ACCOUNT_ID"]="$(echo $PARAM | jq '.[] | select(.Name | test("account_id")) | .Value' --raw-output)"
parameters["ROLE_ARN"]="$(echo $PARAM | jq '.[] | select(.Name | test("assume_role")) | .Value' --raw-output)"
parameters["CLOUDWATCH_LINK"]="$(echo $PARAM | jq '.[] | select(.Name | test("cloudwatch_link")) | .Value' --raw-output)"

parameters["DOCKER_USERNAME"]="$(echo $PARAM2 | jq '.[] | select(.Name | test("username")) | .Value' --raw-output)"
parameters["DOCKER_PASSWORD"]="$(echo $PARAM2 | jq '.[] | select(.Name | test("password")) | .Value' --raw-output)"
