.DEFAULT_GOAL := help
SHELL := '/bin/bash'

ifndef ENV
ENV=development
endif

UID=$(shell id -u)
DOCKER_COMPOSE = env ENV=${ENV} UID=$(UID) docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

DOCKER_IMAGE := ghcr.io/ministryofjustice/nvvs/terraforms:latest

DOCKER_RUN_GEN_ENV := docker run --rm -it \
				--env-file <(aws-vault exec $$AWS_PROFILE -- env | grep ^AWS_) \
				-v `pwd`:/data \
				--workdir /data \
				--platform linux/amd64 \
				$(DOCKER_IMAGE)

.PHONY: shell
shell-aws: ## Run Docker container with interactive terminal
	$(DOCKER_RUN_GEN_ENV) /bin/bash

.PHONY: gen-env
gen-env: ## generate a ".env.ssm.ENV" file checking the AWS environment configuration values e.g. (make gen-env ENV=development|pre-production)
	$(DOCKER_RUN_GEN_ENV) /bin/bash -c "./scripts/generate-env-file.sh ${ENV}"

.PHONY: authenticate_docker
authenticate-docker: ## Authenticate docker script
	./scripts/authenticate_docker.sh

.PHONY: build
build: ## Docker build image
	docker build --platform linux/x86_64 -t admin . --build-arg RACK_ENV --build-arg DB_HOST="" --build-arg DB_USER="" --build-arg DB_PORT --build-arg DB_PASS="" --build-arg SECRET_KEY_BASE="" --build-arg DB_NAME="" --build-arg BUNDLE_WITHOUT --build-arg CLOUDWATCH_LINK=""

.PHONY: build-dev
build-dev: ## Build-dev image
	$(DOCKER_COMPOSE) build --build-arg BUILD_DEV="true"

.PHONY: shell-dev
shell-dev: ## Run application and start shell
	$(DOCKER_COMPOSE) run --rm app sh

.PHONY: start-db
start-db: ## Start database
	$(DOCKER_COMPOSE) up -d db
	ENV=${ENV} ./scripts/wait_for_db.sh

.PHONY: db-setup
db-setup: ## Setup database
	$(MAKE) start-db
	$(DOCKER_COMPOSE) run --rm app ./bin/rails RAILS_ENV=${ENV} db:drop db:create db:migrate

.PHONY: serve
serve: ## Start application
	$(MAKE) stop
	$(MAKE) db-setup
	$(DOCKER_COMPOSE) up -d app
	$(DOCKER_COMPOSE) up -d background_worker

# TODO - this is potentially not needed, but we should check by running tests before removing
# run: serve

.PHONY: clone-integration-test
clone-integration-test: ## Clone nacs integration tests
	git clone https://github.com/ministryofjustice/network-access-control-integration-tests.git

.PHONY: integration-test-schema
integration-test-schema: ## Clone nacs integration tests and test schema
	$(MAKE) clone-integration-test
	cd network-access-control-integration-tests && make clone-server test-schema

.PHONY: test
test: ## Build and run tests
	$(DOCKER_COMPOSE) run -e COVERAGE=true --rm app bundle exec rspec --format documentation

.PHONY: shell
shell: ## Run application and start shell
	$(DOCKER_COMPOSE) run --rm app sh

.PHONY: stop
stop: ## Docker compose down
	$(DOCKER_COMPOSE) down

.PHONY: migrate
migrate: ## Run rails migrate script
	./scripts/migrate.sh

.PHONY: seed
seed: ## Run seed script
	./scripts/seed.sh

.PHONY: migrate-dev
migrate-dev: ## Run rails migrate dev
	$(MAKE) start-db
	$(DOCKER_COMPOSE) run --rm app bundle exec rake db:migrate

.PHONY: bootstrap
bootstrap: ## Run bootstrap script
	./scripts/bootstrap.sh

.PHONY: deploy
deploy: ## Deploy image to ECS
	./scripts/deploy.sh

.PHONY: push
push: ## Push image to ECR
	./scripts/publish.sh

.PHONY: publish
publish: ## Run build and push targets
	$(MAKE) build
	$(MAKE) push

.PHONY: lint
lint: ## Code lint
	$(DOCKER_COMPOSE) run --rm app bundle exec rubocop -a

.PHONY: implode
implode: ## Remove docker container
	$(DOCKER_COMPOSE) rm

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
