DOCKER-RUN = docker-compose run -e TERM -e DISABLE_SPRING_WATCHER_LISTEN=1 --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

# Capture additional command line arguments
# Examples:
# To spin docker cluster up and daemonize: `make up args=-d`
# To run Rubocop and autocorrect: `make rubocop args=-A`
args =

build:
	docker-compose build $(args)

up:
	docker-compose up $(args)

down:
	docker-compose down $(args)

.PHONY: db
db:
	$(DOCKER-RUN) db psql -U postgres -h db -d development

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bash $(args)

guard:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard $(args)

lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop $(args)

debug:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rdbg -nA web 12345

cl:
	$(DOCKER-RUN) web bin/rails console $(args)

rs:
	docker-compose exec web touch tmp/restart.txt

wipe:
	$(DOCKER-RUN) web bin/rails db:reset

seed:
	$(DOCKER-RUN) -e RAILS_ENV=test web bin/rails db:seed
