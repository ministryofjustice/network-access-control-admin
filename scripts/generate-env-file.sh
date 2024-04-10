#!/usr/bin/env bash

## This script will generate checking the AWS environment configuration values

set -x

export ENV="${1:-development}"

printf "\n\nEnvironment is %s\n\n" "${ENV}"

case "${ENV}" in
    development)
        echo "development -- Continuing..."
        ;;
    pre-production)
        echo "pre-production -- Continuing..."
        ;;
    production)
        echo "production shouldn't be running this locally. Exiting..."
        exit 1
        ;;
    *)
        echo "Invalid input."
        ;;
esac

echo "Press 'y' to continue or 'n' to exit."

# Wait for the user to press a key
read -s -n 1 key

# Check which key was pressed
case $key in
    y|Y)
        echo "You pressed 'y'. Continuing..."
        ;;
    n|N)
        echo "You pressed 'n'. Exiting..."
        exit 1
        ;;
    *)
        echo "Invalid input. Please press 'y' or 'n'."
        ;;
esac

# run aws_ssm_get_parameters.sh
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_PATH="${SCRIPT_DIR}/aws_ssm_get_parameters.sh"
. "${SCRIPT_PATH}"

FILE_NAME="./.env.ssm.${ENV}"

cat << EOF > ${FILE_NAME}
# env file
# For checking the AWS environment configuration values
# regenerate by running "./scripts/generate-env-file.sh"
# defaults to "development"
# To test against another environment
# regenerate by running "./scripts/generate-env-file.sh [pre-production | production]"


EOF

for key in "${!parameters[@]}"
do
  echo "${key}=${parameters[${key}]}"  >> ${FILE_NAME}
done

chmod u+x ${FILE_NAME}
