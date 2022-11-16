until [ `docker ps --filter "name=db" --format "{{.Names}}"` ]; do
    echo "waiting for db container...";
    sleep 1;
done;

until [ "`docker inspect -f {{.State.Health.Status}} db`" = "healthy" ]; do
    echo "waiting for db container to be healthy...";
    sleep 1;
done;
