run:
	docker compose up

run-postgres:
	mkdir -p mastodon/postgres/
	docker compose -f docker-compose-postgres.yml \
		up \
		-d
	bash wait-for-db.sh

run-caddy:
	docker compose -f docker-compose-caddy.yml \
		up

setup:
	echo '' > .env.production
	docker compose -f docker-compose.yml \
		run \
		--rm \
		-v $(shell pwd)/.env.production:/opt/mastodon/.env.production \
		web \
		bundle \
		exec \
		rake \
		mastodon:setup

setup-db:
	cp .env.sample .env.production
	docker compose -f docker-compose.yml \
		run \
		--rm \
		-v $(shell pwd)/.env.production:/opt/mastodon/.env.production \
		web \
		bundle \
		exec \
		rake \
		db:setup

rollback:
	touch .env.production
	docker compose -f docker-compose.yml \
		down
	rm -rf caddy/ || true
	rm -rf mastodon/ || true
	rm -rf .env.production || true

all: rollback run-postgres setup-db run
