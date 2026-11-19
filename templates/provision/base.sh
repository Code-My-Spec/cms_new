#!/bin/sh
# What every app on a box shares: the database network, Postgres, a registry.
set -eu
. provision/env.sh
ssh -o BatchMode=yes "$BOX" sh -eu <<'BOX'
docker network inspect db_net >/dev/null 2>&1 || docker network create db_net >/dev/null
docker inspect cms-postgres >/dev/null 2>&1 || docker run -d --name cms-postgres --restart unless-stopped \
  --network db_net -e POSTGRES_PASSWORD="$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')" postgres:16 >/dev/null
mkdir -p /etc/cms-registry && touch /etc/cms-registry/htpasswd
docker inspect cms-registry >/dev/null 2>&1 || docker run -d --name cms-registry --restart unless-stopped \
  -p 5000:5000 -v /etc/cms-registry/htpasswd:/auth/htpasswd \
  -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM=registry -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2 >/dev/null
for i in $(seq 1 60); do docker exec cms-postgres pg_isready -q -U postgres 2>/dev/null && exit 0; sleep 1; done
echo "base: Postgres did not come up"; exit 1
BOX
echo "base: db_net, cms-postgres and cms-registry are there"
