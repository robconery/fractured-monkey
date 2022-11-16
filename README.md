# fractured-monkey

Get mastodon up and running quickly with [docker compose](https://docs.docker.com/compose/) and [Make](https://en.wikipedia.org/wiki/Make_(software)).

## make

Run one of the following commands via `make <command>`

### run

The default command. Will run `docker compose up` once setup has been completed.

### run-postgres

Runs postgres via [docker-compose-postgres.yaml](./docker-compose-postgres.yaml), extracted from [docker-compose.yaml](./docker-compose.yaml), so that we can run it stand-alone and wait for it to be healthy via [wait-for-db.sh](./wait-for-db.sh) that lets us run `setup-db`.

### run-caddy

Runs caddy via [docker-compose-caddy.yaml](./docker-compose-caddy.yaml). This does not currently work, so we have embedded it in [docker-compose.yaml](./docker-compose.yaml) with its own volume.

### setup

Runs mastodon setup interactively. This will create `.env.production`, a sample of which is at [.env.sample](./.env.sample). It will setup the database, and optionally prompt to create an admin account.

### setup-db

Runs mastodon setup non-interactively with values copied from [.env.sample](./.env.sample). It will setup the database but not prompt to create an admin account.

### rollback

Will run `docker compose down` to remove any running containers, and remove `caddy/`, `mastodon/`, which are mounted into the containers, and `.env.production`.

### all

Runs the entire series of `rollback run-postgres setup-db run`.

## Notes

The original setup with Caddy is inspired by [Mastodon Setup with Docker and Caddy](https://blog.riemann.cc/digitalisation/2022/02/09/mastodon-setup-with-docker-and-caddy/), but is based on the upstream [docker-compose.yml](https://github.com/mastodon/mastodon/blob/main/docker-compose.yml) from [mastodon/mastodon](https://github.com/mastodon/mastodon). This makes it easy to diff and track upstream changes.

We are deferring the creation of [.env.sample](./.env.sample) to another script/process for now.

The Caddy web server requires `LETS_ENCRYPT_EMAIL` which is currently hard-coded into `docker-compose.yaml` and `docker-compose-caddy.yaml`.

[Caddyfile](./Caddyfile) uses `tls internal` so that we can access mastodon with TLS at <https://localhost> after running.

We would like to be able to mount `./mastodon/public:/srv/mastodon/public:ro` in [docker-compose-caddy.yml](./docker-compose-caddy.yml) rather than using its own volume but this causes Mastodon to throw errors.
