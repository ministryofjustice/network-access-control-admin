#!/bin/bash

set -eu pipefail

docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASSWORD}
