#!/usr/bin/env bash
# Linux VPS: promote only Lyvora static content; the shared gateway is provisioned separately.
set -Eeuo pipefail
umask 022
bundle=${1:?Lyvora website bundle required}
release=${2:?commit-run-attempt release identity required}
[[ "$release" =~ ^[a-f0-9]{40}-[0-9]+-[0-9]+$ ]] || exit 2
[[ "$bundle" == "/home/budgetify/incoming/lyvora-website-$release.tar.gz" ]] || exit 2
root="$HOME/budgetify"
site="$root/website/lyvora-site"
exec 9>"$root/deploy.lock"
flock -w 600 9
mkdir -p "$site/releases"
target="$site/releases/$release"
[[ ! -e "$target" ]] || { echo 'Release already exists; use a new run attempt' >&2; exit 2; }
stage=$(mktemp -d "$site/releases/.stage.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
# Accept only the known static files. No symlinks, directories, or archive paths.
tar -tzf "$bundle" | while IFS= read -r entry; do
  case "$entry" in
    index.html|download.html|lyvora.css|lyvora-icon.png|404.html|robots.txt|sitemap.xml|revision.txt) ;;
    *) echo "Unexpected bundle entry: $entry" >&2; exit 2 ;;
  esac
done
tar --no-same-owner --no-same-permissions -xzf "$bundle" -C "$stage"
for file in index.html download.html lyvora.css lyvora-icon.png 404.html robots.txt sitemap.xml revision.txt; do
  [[ -f "$stage/$file" && ! -L "$stage/$file" && -s "$stage/$file" ]]
done
[[ "$(cat "$stage/revision.txt")" == "$release" ]]
previous=$(readlink "$site/current" || true)
[[ -z "$previous" || "$previous" =~ ^releases/[a-f0-9]{40}-[0-9]+-[0-9]+$ ]]
mv "$stage" "$target"
promote() {
  ln -s "$1" "$site/.current-$release"
  mv -Tf "$site/.current-$release" "$site/current"
}
rollback() {
  trap - ERR
  if [[ -n "$previous" ]]; then
    promote "$previous"
    echo "Restored previous Lyvora release: $previous" >&2
  else
    rm -f -- "$site/current"
    echo 'First Lyvora publication failed; current link removed' >&2
  fi
  exit 1
}
trap rollback ERR
promote "releases/$release"
# Verify the precise release at the origin without a CDN cache hit.
for host in lyvora-finance.tech; do
  curl --fail --silent --show-error --retry 5 --retry-delay 3 --retry-all-errors --max-time 15 \
    --resolve "$host:443:127.0.0.1" "https://$host/revision.txt" | grep -Fx "$release"
  curl --fail --silent --show-error --max-time 15 --resolve "$host:443:127.0.0.1" \
    "https://$host/download.html" | grep -q 'Download APK'
done
curl --fail --silent --show-error --max-time 20 "https://lyvora-finance.tech/?release=$release" | grep -q 'A little clarity'
curl --fail --silent --show-error --max-time 15 https://afrimed.space/ >/dev/null
curl --fail --silent --show-error --max-time 15 https://lyvora.afrimed.space/health >/dev/null
curl --fail --silent --show-error --max-time 15 https://lyvora-preview.afrimed.space/health >/dev/null
if [[ -n "$previous" ]]; then
  printf '%s\n' "$previous" > "$site/previous-release.txt"
fi
rm -f -- "$bundle"
echo "Published https://lyvora-finance.tech/ at $release"
