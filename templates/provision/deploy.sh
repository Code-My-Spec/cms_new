#!/bin/sh
# Migrate, swap traffic to this commit's image, and check the site answers.
set -eu
. provision/env.sh
[ -n "${KAMAL_REGISTRY_PASSWORD:-}" ] || exec sops exec-env "$ENC" "sh $0"
tag=$(git rev-parse --short=12 HEAD)
export KAMAL_REGISTRY_PASSWORD KAMAL_REGISTRY_USERNAME=$REGISTRY_USER
[ "$SSH_PORT" = 22 ] || export CMS_SSH_PORT=$SSH_PORT
export CMS_IMAGE=$IMAGE:$tag CMS_DEPLOY_HOST=$HOST CMS_DEPLOY_HOST_IP=$BOX_IP CMS_TARGET_ARCH=$ARCH
SOPS_AGE_KEY=$(grep -v '^#' "$KEY") && export SOPS_AGE_KEY
bin/deploy "$ENV_NAME" 2>&1 | tail -40
if [ -n "${BOX_NAME:-}" ]; then
  # A local box has no name the world can reach, so no certificate: ask the app itself.
  ssh -o BatchMode=yes "$BOX" "c=\$(docker ps -q --filter label=service=$APP-$ENV_NAME | head -1); curl -fsS -m 30 -o /dev/null http://\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' \$c | cut -d' ' -f1):4000/health"
  echo "deploy: the app answers on the local box"
else
  curl -fsS -m 30 -o /dev/null "https://$HOST/health"
  echo "deploy: https://$HOST answers"
fi
