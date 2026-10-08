#!/usr/bin/env bash
# Bilingual SystemLog deployment: pinned source files, backup and rollback.
# No changes to Caddy, Cloudflare, DNS, routing or other services.
set -Eeuo pipefail
umask 077

[[ "$EUID" -eq 0 ]] || { echo 'ERROR: run as root'; exit 1; }
SITE=/opt/hs2/edge/sites/systemlog
INDEX="$SITE/index.html"
EN_DIR="$SITE/en"
EN="$EN_DIR/index.html"
BACKUP_DIR=/var/backups/systemlog-portfolio
REV=3db96d87acae119f6ceaa1403857f6a758baf8e2
BASE="https://raw.githubusercontent.com/JanHorans/PROJECT-PREVIEWS/$REV/systemlog-portfolio"
SHA_OLD=6188594805c129abcdf0c7dc71862b6ae953e6bd2d51ffa5ea8672b86bf6a2ff
BLOB_CS=9528f236f5165232bd1f07f7d9234398181a1427
BLOB_EN=318f9f57c323bc8d5f69ce02e3fe394feb777136

[[ -d "$SITE" && -f "$INDEX" && ! -L "$INDEX" ]] || { echo 'ERROR: unexpected current site'; exit 1; }
[[ ! -e "$EN_DIR" && ! -L "$EN_DIR" ]] || { echo 'ERROR: /en already exists; no overwrite'; exit 1; }
command -v git >/dev/null || { echo 'ERROR: git required for blob verification'; exit 1; }
grep -Fq 'root * /opt/hs2/edge/sites/systemlog' /etc/caddy/Caddyfile || { echo 'ERROR: site root not verified'; exit 1; }
printf '%s  %s\n' "$SHA_OLD" "$INDEX" | sha256sum -c - || { echo 'ERROR: changed baseline; no changes made'; exit 1; }

STAGE=$(mktemp -d "$SITE/.bilingual.XXXXXXXX")
CHANGED=0
BACKUP=
cleanup() { rm -rf -- "$STAGE"; }
rollback() {
  status=$?
  trap - ERR
  if (( CHANGED )); then
    echo 'ERROR: deployment verification failed — rolling back'
    temp_restore=$(mktemp "$SITE/.restore.XXXXXXXX")
    cp -p -- "$BACKUP" "$temp_restore"
    mv -f -- "$temp_restore" "$INDEX"
    rm -f -- "$EN"
    rmdir -- "$EN_DIR" 2>/dev/null || true
    echo 'ROLLBACK: COMPLETED'
  fi
  exit "$status"
}
trap cleanup EXIT
trap rollback ERR

curl -fsSL --retry 2 --connect-timeout 8 --max-time 40 -o "$STAGE/cs.html" "$BASE/index.html"
curl -fsSL --retry 2 --connect-timeout 8 --max-time 40 -o "$STAGE/en.html" "$BASE/en/index.html"
[[ "$(git hash-object "$STAGE/cs.html")" == "$BLOB_CS" ]] || { echo 'ERROR: CZ does not match pinned GitHub blob; no changes made'; exit 1; }
[[ "$(git hash-object "$STAGE/en.html")" == "$BLOB_EN" ]] || { echo 'ERROR: EN does not match pinned GitHub blob; no changes made'; exit 1; }
echo 'SOURCE INTEGRITY: CZ and EN verified against pinned GitHub blobs'
grep -Fq '<html lang="cs">' "$STAGE/cs.html"
grep -Fq '<html lang="en">' "$STAGE/en.html"
grep -Fq 'lang-switch' "$STAGE/cs.html"
grep -Fq 'lang-switch' "$STAGE/en.html"

install -d -m 0700 "$BACKUP_DIR"
BACKUP="$BACKUP_DIR/index-$(date -u +%Y%m%dT%H%M%SZ)-bilingual.html"
cp -p -- "$INDEX" "$BACKUP"
chown --reference="$INDEX" "$STAGE/cs.html" "$STAGE/en.html"
chmod --reference="$INDEX" "$STAGE/cs.html" "$STAGE/en.html"

CHANGED=1
install -d -m 0755 "$EN_DIR"
mv -f -- "$STAGE/en.html" "$EN"
mv -f -- "$STAGE/cs.html" "$INDEX"

verify_origin() {
  local route=$1 match=$2 got
  got=$(curl -ksS --noproxy '*' --max-time 15 --resolve systemlog.icu:443:127.0.0.1 "https://systemlog.icu$route")
  grep -Fq "$match" <<< "$got"
}
verify_origin / 'Systémy, které drží pohromadě'
verify_origin /en/ 'Building systems that work'

CHANGED=0
echo 'DEPLOY: PASS — CZ and EN origin verified'
echo "BACKUP: $BACKUP"
echo 'CZ: https://systemlog.icu/'
echo 'EN: https://systemlog.icu/en/'
echo 'NOTE: Cloudflare may still challenge curl.'
