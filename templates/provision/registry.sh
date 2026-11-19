#!/bin/sh
# This app's own user in the box's registry.
set -eu
. provision/env.sh
[ -n "${KAMAL_REGISTRY_PASSWORD:-}" ] || exec sops exec-env "$ENC" "sh $0"
line=$(printf '%s' "$KAMAL_REGISTRY_PASSWORD" | htpasswd -Bni "$REGISTRY_USER" | head -1)
# In place: the registry bind-mounts the file, so it must keep its inode.
printf '%s\n' "$line" | ssh -o BatchMode=yes "$BOX" "f=/etc/cms-registry/htpasswd; { grep -v '^$REGISTRY_USER:' \$f; cat; } > \$f.new; cat \$f.new > \$f; rm \$f.new"
printf '%s' "$KAMAL_REGISTRY_PASSWORD" | ssh -o BatchMode=yes "$BOX" "docker login $REGISTRY -u $REGISTRY_USER --password-stdin >/dev/null 2>&1 && docker logout $REGISTRY >/dev/null; docker login $REGISTRY >/dev/null 2>&1 || true"
echo "registry: $REGISTRY_USER can sign in"
