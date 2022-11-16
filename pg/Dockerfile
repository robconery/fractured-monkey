FROM postgres:14-alpine
COPY mastodon.sql /docker-entrypoint-initdb.d/seed.sql
ENV POSTGRES_USER=docker POSTGRES_PASSWORD=docker POSTGRES_DB=mastodon
EXPOSE 5432