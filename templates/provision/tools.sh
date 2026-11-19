#!/bin/sh
# Every program this project needs on a development machine, all named at once.
set -eu
missing=
for tool in git just mix psql docker sops age curl; do
  command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
done
[ -z "$missing" ] || { echo "tools: not installed:$missing (on a Mac: brew install$missing)"; exit 1; }
pg_isready -q || { echo "tools: Postgres is not answering on this machine; start it"; exit 1; }
echo "tools: all present"
