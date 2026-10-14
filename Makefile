.PHONY: build up down restart bash tests cucumber ci

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

bash:
	docker compose exec web bash

tests:
	docker compose exec web bundle exec rspec

cucumber:
	docker compose exec web bundle exec cucumber

ci:
	./bin/ci
