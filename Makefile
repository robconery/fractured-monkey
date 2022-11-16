# setup:
# 	touch mastodon.env.production
# 	docker compose run --rm -v $(shell pwd)/mastodon.env.production:/opt/mastodon/.env.production -e RUBYOPT=-W0 mastodon-web bundle exec rake mastodon:setup

# rollback:
# 	docker-compose down
# 	rm -rf caddy/
# 	rm -rf mastodon/
# 	rm -rf mastodon.env.production

# db-setup:
# 	cp mastodon.env.sample mastodon.env.production
# 	docker compose run --rm -v $(shell pwd)/mastodon.env.production:/opt/mastodon/.env.production -e RUBYOPT=-W0 mastodon-web bundle exec rake db:setup

# run:
# 	docker-compose up




.PHONY: setup-db run delete
