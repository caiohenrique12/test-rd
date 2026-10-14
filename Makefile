.PHONY: build up down restart bash tests

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
	docker compose run --rm web bundle exec rspec
