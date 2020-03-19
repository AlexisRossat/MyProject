-include .env
-include .env.local
#-include .env.$(APP_ENV)
#-include .env.$(APP_ENV).local

export APP_ENV

#Par défaut APP_ENV=DEV
ifndef APP_ENV
	APP_ENV=dev
endif

#Utilisée par composer
NO-DEV=
ENV=dev

#Variables pour la qualif
ifeq ($(APP_ENV),qualif)
	NO-DEV=--no-dev --optimize-autoloader
	ENV=prod
endif

#Variables pour la prod
ifeq ($(APP_ENV),prod)
	NO-DEV=--no-dev --optimize-autoloader
	ENV=prod
endif


DOCKER_COMPOSE=docker-compose
TOOLS= ${DOCKER_COMPOSE} exec $(IN_CI) web
QA=${DOCKER_COMPOSE} run $(IN_CI) --rm  quality-tools
SYMFONY=${TOOLS} php bin/console

#################################
Docker:

## Build the docker stack
docker-build:
	${DOCKER_COMPOSE} build
.PHONY: docker-build

## Run the docker stack
docker-up:
	${DOCKER_COMPOSE} up -d --remove-orphans

## Kill the docker stack
docker-kill:
	${DOCKER_COMPOSE} kill

## Remove the docker stack images
docker-rm:
	${DOCKER_COMPOSE} rm -f

## Exécute un bash dans le container web (avec apache + composer + node)
docker-bash-web:
	${TOOLS} /bin/bash

#################################
Project:

## Start the project
start: docker-build docker-up install-dependencies #webpack-build

## Stop and remove the project containers
stop: docker-kill docker-rm

## Reset the project
restart: stop start reset-db

## Show the project realtime logs
logs:
	${DOCKER_COMPOSE} logs -f

## Install Composer packages
composer:
	${TOOLS} composer install ${NO-DEV}

## Install Node packages
node:
	#${TOOLS} yarn install

## Install the project dependencies
install-dependencies: composer node chown-user

## Chown User sur .
chown-user:
	${TOOLS} chown -R 1000:1000 .

#################################
Database:

## Drop database
drop-db:
	${SYMFONY} doctrine:database:drop --force --if-exists || true

## Create database
create-db:
	${SYMFONY} doctrine:database:create --if-not-exists || true

## Crée un fichier de migration
migration:
	${SYMFONY} doctrine:migration:diff

## Update the database Schema
migrate: update-schema

update-schema:
	${SYMFONY} doctrine:migration:migrate --no-interaction

## Create the Database and then update the schema
init-db: create-db update-schema load-fixtures

## Create the Database and then update the schema
reset-db: drop-db init-db

## Load test fixture data into the database
load-fixtures:
	${SYMFONY}  hautelook:fixtures:load -q --env=${APP_ENV}

#################################
Quality-Assurance:

## Check Symfony Dependencies for security vulnerabilities
security-check:
	${QA} security-checker security:check

## Check PHP-Code-Sniffer violations without fixing them
cs-check:
	${QA} php-cs-fixer fix --dry-run --diff --verbose --using-cache=no

## Fix PHP-Code-Sniffer Violations
cs-fix:
	${QA} php-cs-fixer fix --diff --verbose --using-cache=no

#################################
Webpack-Encore: 

## Webpack encore (yarn encore ENV)
webpack-build:
	${TOOLS} yarn encore ${ENV}

## Webpack watcher (yarn encore ENV --watch)
webpack-watcher:
	${TOOLS} yarn encore ${ENV} --watch

#################################
Symfony:

## Cache warmup
symfony-cache-warmup:
	${SYMFONY} cache:warmup

## Cache clear
symfony-cache-clear:
	${SYMFONY} cache:clear --no-warmup

## Install assets
symfony-assets-install:
	${SYMFONY} assets:install public/ --symlink --relative

#################################
Debug:

## Dump la variable APP_ENV et DATABASE_URL
app-env:
	${TOOLS} echo ${APP_ENV} ${DATABASE_URL}

## Execute un printenv sur le container web
printenv:
	${TOOLS} printenv

#################################
.DEFAULT_GOAL := help

ifndef CI_JOB_ID
	   # COLORS
	   GREEN  := $(shell tput -Txterm setaf 2)
	   YELLOW := $(shell tput -Txterm setaf 3)
	   WHITE  := $(shell tput -Txterm setaf 7)
	   RESET  := $(shell tput -Txterm sgr0)
	   TARGET_MAX_CHAR_NUM=30
endif

help:
	   @echo "${GREEN}MyProject{RESET} https://myProject.com"
	   @awk '/^[a-zA-Z\-\_0-9]+:/ { \
			  helpMessage = match(lastLine, /^## (.*)/); \
			  if (helpMessage) { \
					 helpCommand = substr($$1, 0, index($$1, ":")); helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
					 printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
			  } \
			  isTopic = match(lastLine, /^###/); \
		   if (isTopic) { printf "\n%s\n", $$1; } \
	   } { lastLine = $$0 }' $(MAKEFILE_LIST)
