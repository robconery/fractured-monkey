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

### config-mastodon

Uses `sed` to inject `SITE_ADDRESS` into `.env.sample` and output the result to `.env.production`.

### config-secrets

Generates `SECRET_KEY_BASE`, `OTP_SECRET`, `VAPID_PRIVATE_KEY`, and `VAPID_PUBLIC_KEY` using `rake secret` and `rake mastodon:webpush:generate_vapid_key` respectively, and appends them to `.env.production`. See [secrets](https://docs.joinmastodon.org/admin/config/#secrets) for more details. This is run after `config-caddy` as it uses `docker-compose.yml` which depends on `.env.caddy.production` existing.

### config-caddy

Uses `sed` to inject `LETS_ENCRYPT_EMAIL` and `SITE_ADDRESS` into `.env.caddy.sample` and outputs the result to `.env.caddy.production`. It appends `TLS_INTERNAL` to the file, which defaults to `tls internal` for the purposes of local testing. This should be empty for production use.

### config

Runs `config-mastodon` and `config-caddy`.

### setup

Runs mastodon setup interactively. This will create `.env.production`, a sample of which is at [.env.sample](./.env.sample). It will setup the database, and optionally prompt to create an admin account.

### setup-db

Runs mastodon setup non-interactively with values copied from [.env.sample](./.env.sample). It will run `config-caddy` prior to execution. It will setup the database but not prompt to create an admin account.

### setup-admin

This uses the [tootctl accounts create](https://docs.joinmastodon.org/admin/tootctl/#accounts-create) and the `web` container to create an account with the `Owner` role which you can use to login to your instance. We usually output the result of this elsewhere (e.g. `~/admin.txt`) during VM setup so that we can access it later.

### rollback

Will run `docker compose down` to remove any running containers, and remove `caddy/`, `mastodon/`, which are mounted into the containers, as well as `.env.production and `.env.caddy`.

### all

Runs the entire series of `rollback run-postgres config setup-db setup-admin run`.

## Notes

The original setup with Caddy is inspired by [Mastodon Setup with Docker and Caddy](https://blog.riemann.cc/digitalisation/2022/02/09/mastodon-setup-with-docker-and-caddy/), but is based on the upstream [docker-compose.yml](https://github.com/mastodon/mastodon/blob/main/docker-compose.yml) from [mastodon/mastodon](https://github.com/mastodon/mastodon). This makes it easy to diff and track upstream changes.

We are deferring the creation of [.env.sample](./.env.sample) to another script/process for now.

The Caddy web server requires `LETS_ENCRYPT_EMAIL` which is currently hard-coded into `docker-compose.yaml` and `docker-compose-caddy.yaml`.

[Caddyfile](./Caddyfile) uses `tls internal` so that we can access mastodon with TLS at <https://localhost> after running.

We would like to be able to mount `./mastodon/public:/srv/mastodon/public:ro` in [docker-compose-caddy.yml](./docker-compose-caddy.yml) rather than using its own volume but this causes Mastodon to throw errors.
