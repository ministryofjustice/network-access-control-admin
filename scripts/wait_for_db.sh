#!/bin/bash

set -euo pipefail

printf "Waiting for database to be ready"
until docker-compose exec -T db /bin/bash -c 'mysql -h127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"' &> /dev/null
do
  printf "."
  sleep 1
done

env
docker ps
