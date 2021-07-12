ifndef ENV
ENV=development
endif

UID=$(shell id -u)
DOCKER_COMPOSE = env ENV=${ENV} UID=$(UID) docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

authenticate-docker: check-container-registry-account-id
	./scripts/authenticate_docker.sh

check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build: check-container-registry-account-id
	docker build -t admin . --build-arg RACK_ENV --build-arg DB_HOST --build-arg DB_USER --build-arg DB_PORT --build-arg DB_PASS --build-arg SECRET_KEY_BASE --build-arg DB_NAME --build-arg BUNDLE_WITHOUT --build-arg SHARED_SERVICES_ACCOUNT_ID

build-dev:
	$(DOCKER_COMPOSE) build

start-db:
	$(DOCKER_COMPOSE) up -d db
	ENV=${ENV} ./scripts/wait_for_db.sh

db-setup: start-db
	$(DOCKER_COMPOSE) run --rm app ./bin/rails db:drop db:create db:schema:load

serve: stop start-db
	$(DOCKER_COMPOSE) up app

run: serve

test: export ENV=test
test:
	$(DOCKER_COMPOSE) run -e COVERAGE=true --rm app bundle exec rake

shell:
	$(DOCKER_COMPOSE) run --rm app sh

stop:
	$(DOCKER_COMPOSE) down

migrate:
	./scripts/migrate.sh

migrate-dev: start-db
	$(DOCKER_COMPOSE) run --rm app bundle exec rake db:migrate

bootstrap:
	./scripts/bootstrap.sh

deploy:
	./scripts/deploy.sh

push:
	./scripts/publish.sh

publish: build push

lint:
	$(DOCKER_COMPOSE) run --rm app bundle exec rubocop -a

implode:
	$(DOCKER_COMPOSE) rm

.PHONY: build serve stop test deploy migrate migrate-dev build-dev push publish implode authenticate-docker check-container-registry-account-id start-db db-setup run shell lint bootstrap
