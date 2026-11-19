#!/bin/sh
# An age key for this environment and the app's secrets encrypted to it.
set -eu
. provision/env.sh
[ -f "$KEY" ] || { mkdir -p "$(dirname "$KEY")"; age-keygen -o "$KEY" 2>/dev/null; chmod 600 "$KEY"; }
pub=$(age-keygen -y "$KEY")
if sops -d "$ENC" 2>/dev/null | grep -q '^DATABASE_URL='; then echo "secrets: $ENC already opens"; exit 0; fi
perl -pi -e "s/<$(echo "$ENV_NAME" | tr a-z A-Z)_AGE_PUBLIC_KEY>/$pub/" .sops.yaml
grep -q "$pub" .sops.yaml || { echo "secrets: .sops.yaml names another key for $ENV_NAME"; exit 1; }
rand() { openssl rand -hex "$1"; }
db_pw=$(rand 24)
printf 'SECRET_KEY_BASE=%s\nDB_PASSWORD=%s\nDATABASE_URL=ecto://%s:%s@cms-postgres/%s\nKAMAL_REGISTRY_PASSWORD=%s\n' \
  "$(rand 48)" "$db_pw" "$DB" "$db_pw" "$DB" "$(rand 24)" |
  sops encrypt --filename-override "$ENC" --input-type dotenv --output-type dotenv /dev/stdin > "$ENC.new"
mv "$ENC.new" "$ENC"
git add .sops.yaml "$ENC"
git commit -q -m "provision: $ENV_NAME secrets, encrypted" -- .sops.yaml "$ENC"
echo "secrets: wrote $ENC"
