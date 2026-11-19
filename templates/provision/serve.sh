#!/bin/sh
# The app starts on this machine and answers.
set -eu
port=${PROVISION_PORT:-4199}
PORT=$port MIX_ENV=dev mix phx.server >/dev/null 2>&1 &
pid=$!
trap 'kill $pid 2>/dev/null || true' EXIT
for i in $(seq 1 90); do
  curl -fsS -o /dev/null "http://localhost:$port/health" 2>/dev/null && { echo "serve: http://localhost:$port answers"; exit 0; }
  kill -0 $pid 2>/dev/null || { echo "serve: the app stopped while starting; run 'mix phx.server' to see why"; exit 1; }
  sleep 1
done
echo "serve: no answer on port $port after 90 seconds"; exit 1
