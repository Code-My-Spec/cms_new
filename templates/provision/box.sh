#!/bin/sh
# A box from nothing, in Docker on this machine: one container with a Docker
# and an sshd of its own, reachable as root on a loopback port. Always one per
# app, by name: any earlier one is taken away first, so runs never pile up.
set -eu
. provision/env.sh
[ -n "${BOX_NAME:-}" ] || { echo "box: this target's box is not made here"; exit 1; }
docker rm -fv "$BOX_NAME" >/dev/null 2>&1 || true
docker run -d --privileged --name "$BOX_NAME" --label "cms-box=$APP" \
  -p "127.0.0.1:$SSH_PORT:22" -e PUB="$(cat "$HOME"/.ssh/id_*.pub)" docker:27-dind sh -c '
    # The image pins openssh-client-common at its build version; upgrade it
    # with the server so a newer repo index does not break the install.
    apk add -q --no-cache --upgrade openssh openssh-client-common openssh-keygen curl >/dev/null || exit 1
    ssh-keygen -A >/dev/null
    mkdir -p /root/.ssh && echo "$PUB" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys
    sed -i "s/^root:!/root:*/" /etc/shadow
    /usr/sbin/sshd
    exec dockerd-entrypoint.sh' >/dev/null
ssh-keygen -R "[$BOX_IP]:$SSH_PORT" >/dev/null 2>&1 || true
for i in $(seq 1 60); do
  if ssh-keyscan -p "$SSH_PORT" "$BOX_IP" 2>/dev/null | grep -q .; then
    ssh-keyscan -p "$SSH_PORT" "$BOX_IP" 2>/dev/null >> "$HOME/.ssh/known_hosts"
    ssh -o BatchMode=yes "$BOX" docker info >/dev/null 2>&1 && { echo "box: $BOX_NAME is up at $BOX"; exit 0; }
    ssh-keygen -R "[$BOX_IP]:$SSH_PORT" >/dev/null 2>&1 || true
  fi
  sleep 2
done
echo "box: $BOX_NAME did not answer over ssh with Docker running"; docker logs --tail 20 "$BOX_NAME" 2>&1; exit 1
