run:
	docker-compose up -d

run-postgres:
	mkdir -p mastodon/postgres/
	docker-compose -f docker-compose-postgres.yml \
		up \
		-d
	bash wait-for-db.sh

run-caddy:
	docker-compose -f docker-compose-caddy.yml \
		up

LETS_ENCRYPT_EMAIL ?= admin@localhost
SITE_ADDRESS ?= localhost

config-mastodon:
	@sed -e "s;example.com;$(SITE_ADDRESS);g" .env.sample | \
		tee .env.production

config-caddy:
	@sed -e "s;admin@example.com;$(LETS_ENCRYPT_EMAIL);g" .env.caddy.sample | \
		sed -e "s;example.com;$(SITE_ADDRESS);g" | \
		tee .env.caddy.production

	@echo "" | tee -a .env.caddy.production
	
	@echo "TLS_INTERNAL=tls internal" | tee -a .env.caddy.production

config: config-mastodon config-caddy

setup: config-caddy
	echo '' > .env.production
	docker-compose -f docker-compose.yml \
		run \
		--rm \
		-v ${PWD}/.env.production:/opt/mastodon/.env.production \
		web \
		bundle \
		exec \
		rake \
		mastodon:setup

setup-db: config
	docker-compose -f docker-compose.yml \
		run \
		--rm \
		-v ${PWD}/.env.production:/opt/mastodon/.env.production \
		web \
		bundle \
		exec \
		rake \
		db:setup

setup-admin:
	docker-compose -f docker-compose.yml \
		run \
		--rm \
		-v ${PWD}/.env.production:/opt/mastodon/.env.production \
		web \
		bin/tootctl accounts create \
		me \
		--email me@${SITE_ADDRESS} \
		--confirmed \
		--role Owner

rollback:
	touch .env.production
	touch .env.caddy.production
	docker-compose -f docker-compose.yml \
		down
	rm -rf caddy/ || true
	rm -rf mastodon/ || true
	rm -rf .env.production || true
	rm -rf .env.caddy.production || true

all: rollback run-postgres setup-db setup-admin run
