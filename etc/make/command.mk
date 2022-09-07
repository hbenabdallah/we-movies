## @Application Display application version
version:
	@cat VERSION
	@printf "\n"

## @Application Start application
start: start-proxy docker-network docker-start
	@printf " - Successful ${GREEN}start application${RESET} project\n"
	@printf " - Welcome !! The project is available on this url: ${YELLOW}${PROJECT_URL}${RESET}\n"

## @Application Stop application
stop: docker-stop
	@printf " - Successful ${GREEN}stopping${RESET} of the application\n"

## @Application Start nginx and dns proxy application
start-proxy:
ifneq ("$(wildcard bin/docker-compose)","")
	@$(NGINX_PROXY)
	@$(DNS_PROXY)
endif

## @Install Install application to <env> environment (Default <env> = dev)
install: build-env start-proxy install-npm install-deps docker-network install-hosts install-assets cache-clear
	$(shell echo "Application installed!" >> .install)
	@printf " - Welcome !! now execute ${GREEN}make start${RESET} to launch all services in the project.\n"

## @Install Install hosts and apply permission rules on directory project
install-hosts:
	@printf " - Apply permission rules on directory ${GREEN}logs${RESET} and ${GREEN}cache${RESET}\n"
	@bin/docker-compose run --rm hosts bash -c "grep -q -F '127.0.0.1 ${VIRTUAL_HOST}' $(HOSTS_ETC)/hosts || echo '127.0.0.1 ${VIRTUAL_HOST}' >> ${HOSTS_ETC}/hosts"

## @Install Install symfony assets
install-assets:
	@printf " - Install ${GREEN}symfony${RESET} assets\n"
	@bin/php bin/console assets:install

## @Install Install npm dependencies project <env> environment (Default <env> = dev)
install-npm:
	@printf " - Installing ${GREEN}npm${RESET} dependencies\n"
	@bin/node bash -c "npm prune && npm install"

## @Install Install php dependencies project <env> environment (Default <env> = dev)
install-deps:
	@printf " - Installing ${GREEN}php${RESET} ${ENV}-dependencies\n"
ifeq ($(ENV), dev)
	@bin/composer update --optimize-autoloader --prefer-dist --no-interaction
else
	@bin/composer update --no-dev --optimize-autoloader --prefer-dist --no-interaction
endif

## @Install Delete all temporary file and directory
uninstall:
	@printf " - Removing ${GREEN}temporary file and directory${RESET} \n"
	@rm -f etc/node/package-lock.json > /dev/null 2>&1
	@rm -rf etc/node/node_modules > /dev/null 2>&1
	@rm -rf vendor > /dev/null 2>&1
	@rm -rf var/cache/* > /dev/null 2>&1
	@rm -rf var/log/* > /dev/null 2>&1
	@rm -f .env > /dev/null 2>&1
	@rm -f .install > /dev/null 2>&1
	@printf " - Successful ${GREEN}clean${RESET} project\n"

## @Install Update all dependencies application to <env>\n environment (Default <env> = dev)
update: stop uninstall
	@rm -f composer.lock > /dev/null 2>&1
	$(MAKE) install

## @Build Build webpack assets configuration
build-webpack:
	@printf " - Generating ${GREEN}assets${RESET}\n"
	@bin/node npm run dev

## @Build Build environment configuration
build-env:
	@printf " - Build ${GREEN}.env${RESET} \n"
	$(shell cat ${PWD}/etc/.env.dist > .env)
	$(shell echo "UID=$(UID)" >> .env)
	$(shell echo "GID=$(GID)" >> .env)
	$(shell echo "USER_NAME=$(USER_NAME)" >> .env)
	$(shell echo "PATH=$(PATH)" >> .env)
	$(shell echo "PWD=$(PWD)" >> .env)
	$(shell echo "NETWORK=$(DOCKER_NETWORK)" >> .env)
	$(shell echo "COMPOSER_CACHE=$(COMPOSER_CACHE)" >> .env)
	$(shell echo "NPM_CACHE=$(NPM_CACHE)" >> .env)

## @Application Clear symfony cache
cache-clear:
	@printf " - Clear ${GREEN}Symfony${RESET} cache\n"
	@bin/php bin/console cache:clear

## @Docker Start all container dockers to run application
docker-start:
	@bin/docker-compose up -d app

## @Docker Stop all running containers in the application
docker-stop:
	@bin/docker-compose down
	#@docker system prune -f

## @Docker Access the command line interface of container name
docker-main:
	@docker exec -ti "$(shell docker ps -qf "name=app_${PROJECT_NAME}" )" bash

## @Docker Access the command line interface of container name
docker-mysql:
	@docker exec -ti "$(shell docker ps -qf "name=sql_${PROJECT_NAME}" )" bash

## @Docker Create default network
docker-network:
	@docker network inspect $(DOCKER_NETWORK)_default >/dev/null || docker network create $(DOCKER_NETWORK)_default

## @Database Create migration
create-migration:
	@printf " - Create ${GREEN}Migration${RESET} \n"
	@bin/php bin/console make:migration

## @Database Create fixture
create-fixture:
	@printf " - Create ${GREEN}Fixture${RESET} \n"
	@bin/php bin/console make:fixtures

## @Database Load fixture
load-fixture:
	@printf " - Load ${GREEN}Fixture${RESET} \n"
	@bin/php bin/console doctrine:fixtures:load --append -n

## @Database Migration database
database-migrate:
	@printf " - Migrate ${GREEN}Database${RESET} \n"
	@bin/php bin/console  doctrine:migrations:migrate -n

## @Database Update database
database-update:
	@printf " - Update ${GREEN}Database${RESET} \n"
	@bin/php bin/console doctrine:schema:update --force
