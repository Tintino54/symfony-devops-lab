# Makefile - helpers for entering the app container and running Symfony console
# Usage:
#   make enter CONTAINER=<container-name>
#   make debug-router CONTAINER=<container-name>


CONTAINER ?= symfony-app

.PHONY: enter router

enter:
	@docker exec -it $(CONTAINER) bash

rebuild:
	@docker build -t symfony-devops-lab .
router:
	@docker exec -it $(CONTAINER) php bin/console debug:router

