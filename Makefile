MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))

# Load environment vars
include ${PWD}/etc/.env.dist
export $(shell sed 's/=.*//' ${PWD}/etc/.env.dist)

PROJECT_URL=http://${VIRTUAL_HOST}
NPM_CACHE=$(HOME)/.npm
COMPOSER_CACHE=$(HOME)/.composer/cache
USER_NAME ?= $(shell id -u -n)
UID ?= $(shell id -u)
GID ?= $(shell id -g)
PWD ?= $(shell pwd)
PATH?=$(shell echo $PATH)
NGINX_PROXY=bin/docker-compose -f etc/docker/docker-compose.nginx-proxy.yml -p $(DOCKER_NETWORK) up -d || true
DNS_PROXY=bin/docker-compose -f etc/docker/docker-compose.dns-proxy.yml -p $(DOCKER_NETWORK) up -d || true

ifeq ($(shell uname -s),Darwin)
	OS=osx
else
	OS=linux
endif

include etc/make/help.mk
include etc/make/command.mk
