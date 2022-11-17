#setup:
#	touch mastodon.env.production
#	docker compose run --rm -v $(shell pwd)/mastodon.env.production:/opt/mastodon/.env.production -e RUBYOPT=-W0 mastodon bundle exec rake mastodon:setup

db-setup:
	cp mastodon.env.sample mastodon.env
	docker-compose -f docker-compose-pg.yaml up -d
	sleep 5
	docker compose run --rm -v $(shell pwd)/mastodon.env:/opt/mastodon/.env.production -e RUBYOPT=-W0 mastodon bundle exec rake db:setup

rollback:
	docker-compose down
	rm -rf caddy/
	rm -rf mastodon/
	rm -rf mastodon.env.production
	
rollback-sudo:
	docker-compose down
	sudo rm -rf caddy/
	sudo rm -rf mastodon/
	sudo rm -rf mastodon.env.production

run:

	docker-compose up

.PHONY: setup-db run delete
