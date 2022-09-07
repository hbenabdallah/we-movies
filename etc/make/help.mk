# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
VIOLET := $(shell tput -Txterm setaf 5)
BlUE := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)
NEWLINE := $(shell printf '\010')

HELP_TARGET_MAX_CHAR_NUM = 20

help:
	@echo ''
	@echo '   Usage:'
	@echo ''
	@echo '   ${YELLOW}make${RESET} ${GREEN}[command]${RESET} ${BlUE}[arguments]${RESET}'
	@echo ''
	@echo '   Available commands'
	@echo ''
	@echo '     ${GREEN}help${RESET}                 Display this help message'
	@echo ''
	@awk '/^[a-zA-Z\-\_0-9]+:/ \
		{ \
			helpMessage = match(lastLine, /^## (.*)/); \
			if (helpMessage) { \
				helpCommand = substr($$1, 0, index($$1, ":")); \
				gsub(":", "", helpCommand); \
				helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
				helpGroup = match(helpMessage, /^@([^ ]*)/); \
				if (helpGroup) { \
					helpGroup = substr(helpMessage, RSTART + 1, index(helpMessage, " ")-2); \
					helpMessage = substr(helpMessage, index(helpMessage, " ")+1); \
				} \
				printf " %s|  ${GREEN} %-$(HELP_TARGET_MAX_CHAR_NUM)s ${RESET}%s\n", \
					helpGroup, helpCommand, helpMessage; \
			} \
		} \
		{ lastLine = $$0 }' \
		$(MAKEFILE_LIST) \
	| sort -t'|' -sk1,1 \
	| awk -F '|' ' \
			{ \
			cat = $$1; \
			if (cat != lastCat || lastCat == "") { \
				if ( cat == "0" ) { \
					print "  Targets:" \
				} else { \
					gsub("_", " ", cat); \
					printf " ${YELLOW} %s: ${RESET}\n", cat; \
				} \
			} \
			printf "  %s\n", $$2 \
		} \
		{ lastCat = $$1 }'
	@echo ''

default: help