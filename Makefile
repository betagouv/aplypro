DOCKER-RUN = docker-compose run --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bash

guard:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard

debug:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rdbg -A web 12345
