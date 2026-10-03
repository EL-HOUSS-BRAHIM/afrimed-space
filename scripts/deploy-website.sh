#!/usr/bin/env bash
# Publish the public Afrimed introduction without changing backend images.
set -Eeuo pipefail
umask 022
bundle=${1:?website bundle path required}
[[ "$bundle" =~ ^/home/budgetify/incoming/website-[a-zA-Z0-9.-]+\.tar\.gz$ ]] || exit 2
root="$HOME/budgetify"
gateway="$root/gateway"
mkdir -p "$gateway" "$root/website"
exec 9>"$root/deploy.lock"
flock -w 600 9
stage=$(mktemp -d "$root/.website.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
tar -xzf "$bundle" -C "$stage"
[[ -s "$stage/site/index.html" && -s "$stage/site/styles.css" ]]
docker run --rm -v "$stage/Caddyfile.gateway:/etc/caddy/Caddyfile:ro" caddy:2-alpine caddy validate --config /etc/caddy/Caddyfile
cp "$gateway/compose.yaml" "$stage/previous.compose.yaml"
cp "$gateway/Caddyfile.gateway" "$stage/previous.Caddyfile"
cp -a "$root/website" "$stage/previous.site"
rollback() {
  trap - ERR
  cp "$stage/previous.compose.yaml" "$gateway/compose.yaml"
  cp "$stage/previous.Caddyfile" "$gateway/Caddyfile.gateway"
  cp -a "$stage/previous.site/." "$root/website/"
  docker compose -f "$gateway/compose.yaml" up -d
  docker compose -f "$gateway/compose.yaml" exec -T proxy caddy reload --config /etc/caddy/Caddyfile
  echo 'Website deployment failed; previous gateway restored' >&2
  exit 1
}
trap rollback ERR
# Keep the mounted directory inode stable for the running proxy.
cp -a "$stage/site/." "$root/website/"
cp "$stage/compose.gateway.yaml" "$gateway/compose.yaml"
cp "$stage/Caddyfile.gateway" "$gateway/Caddyfile.gateway"
docker compose -f "$gateway/compose.yaml" up -d
docker compose -f "$gateway/compose.yaml" exec -T proxy caddy reload --config /etc/caddy/Caddyfile
ready=false
for attempt in $(seq 1 12); do
  if curl --fail --silent --max-time 15 https://afrimed.space/ | grep -q 'A little curiosity'; then
    ready=true
    break
  fi
  sleep 5
done
$ready
curl --fail --silent --max-time 15 https://lyvora.afrimed.space/health
curl --fail --silent --max-time 15 https://lyvora-preview.afrimed.space/health
cp "$stage/previous.compose.yaml" "$gateway/website-previous.compose.yaml"
cp "$stage/previous.Caddyfile" "$gateway/website-previous.Caddyfile"
rm -f -- "$bundle"
echo 'Published https://afrimed.space'
