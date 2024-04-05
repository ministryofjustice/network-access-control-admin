#!/usr/bin/env bash

## This script will generate .env file for use with the Makefile
## or to export the TF_VARS into the environment

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

FILE_NAME="./.env.TEST1"

cat << EOF > ${FILE_NAME}
# env file
# regenerate by running "./scripts/generate-env-file.sh"
# defaults to "development"
# To test against another environment
# regenerate by running "./scripts/generate-env-file.sh [pre-production | production]"
# Also run "make clean"
# then run "make init"




EOF

for key in "${!parameters[@]}"
do
  echo "${key}=${parameters[${key}]}"  >> ${FILE_NAME}
done

chmod u+x ./.env
