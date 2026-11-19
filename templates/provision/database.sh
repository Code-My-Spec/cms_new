#!/bin/sh
# This app's role and database in the box's shared Postgres.
set -eu
. provision/env.sh
[ -n "${DB_PASSWORD:-}" ] || exec sops exec-env "$ENC" "sh $0"
ssh -o BatchMode=yes "$BOX" docker exec -i cms-postgres psql -U postgres -v ON_ERROR_STOP=1 -q <<SQL
DO \$\$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB') THEN CREATE ROLE "$DB" LOGIN; END IF;
END \$\$;
ALTER ROLE "$DB" PASSWORD '$DB_PASSWORD';
SELECT 'CREATE DATABASE "$DB" OWNER "$DB"' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB') \gexec
SQL
echo "database: $DB is there"
