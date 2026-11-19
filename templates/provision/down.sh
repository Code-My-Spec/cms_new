#!/bin/sh
# Take the local box away and show that nothing of it is left.
set -eu
. provision/env.sh
[ -n "${BOX_NAME:-}" ] || { echo "down: this target's box is not ours to take away"; exit 1; }
docker rm -fv "$BOX_NAME" >/dev/null 2>&1 || true
ssh-keygen -R "[$BOX_IP]:$SSH_PORT" >/dev/null 2>&1 || true
left=$(docker ps -aq --filter "label=cms-box=$APP")
[ -z "$left" ] || { echo "down: still there: $left"; exit 1; }
echo "down: $BOX_NAME is gone"
