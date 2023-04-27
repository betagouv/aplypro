DOCKER-RUN = docker-compose run --rm
BUNDLE-EXEC = bundle exec

build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) sh

guard:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard
