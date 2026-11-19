#!/bin/sh
# Build this commit's image here and put it in the box's registry.
set -eu
. provision/env.sh
[ -n "${KAMAL_REGISTRY_PASSWORD:-}" ] || exec sops exec-env "$ENC" "sh $0"
tag=$(git rev-parse --short=12 HEAD)
# shortcut: pushed from the box, because the registry is on its private network; give the builder a route in when builds leave this machine.
if ssh -o BatchMode=yes "$BOX" "docker image inspect $IMAGE:$tag >/dev/null 2>&1"; then
  echo "image: $IMAGE:$tag already loaded on the box"
else
  docker build -q --platform "linux/$ARCH" --label "service=$APP-$ENV_NAME" -t "$IMAGE:$tag" .
  docker save "$IMAGE:$tag" | gzip | ssh -o BatchMode=yes "$BOX" "gunzip | docker load -q"
  # Nothing of the build stays on this machine's Docker.
  docker rmi "$IMAGE:$tag" >/dev/null
fi
# The box keeps no sign-in of its own (registry.sh logs out), so push as this
# app's registry user, password over stdin, and sign out again after.
printf '%s' "$KAMAL_REGISTRY_PASSWORD" | ssh -o BatchMode=yes "$BOX" \
  "docker login $REGISTRY -u $REGISTRY_USER --password-stdin >/dev/null && { docker push -q $IMAGE:$tag; s=\$?; docker logout $REGISTRY >/dev/null; exit \$s; }"
echo "image: pushed $IMAGE:$tag"
