#!/usr/bin/env bash
# SystemLog 1.0 PUBLIC deployment. CZ/EN only. Private history must not be deployed by this script.
set -Eeuo pipefail
umask 077

[[ ${EUID:-$(id -u)} -eq 0 ]] || { echo 'ERROR: run as root on HS2'; exit 1; }
SITE=/opt/hs2/edge/sites/systemlog
CS="$SITE/index.html"
EN="$SITE/en/index.html"
BACKUPS=/var/backups/systemlog-portfolio
REV=d34de9bc0e3d8976445d344df6002084da26fd63
BASE="https://raw.githubusercontent.com/JanHorans/PROJECT-PREVIEWS/${REV}/systemlog-portfolio"
OLD_CS=9528f236f5165232bd1f07f7d9234398181a1427
OLD_EN=318f9f57c323bc8d5f69ce02e3fe394feb777136
NEW_CS=93ed6dcfa53d40c798c334405437bf41ef8c68fb
NEW_EN=0bba58aa766930ff8f37130f53376a83792580bc

for cmd in curl git mktemp cp mv sha256sum; do command -v "$cmd" >/dev/null || { echo "ERROR: missing $cmd"; exit 1; }; done
[[ -d "$SITE" && -f "$CS" && ! -L "$CS" ]] || { echo 'ERROR: unexpected CZ site'; exit 1; }
[[ -d "$SITE/en" && -f "$EN" && ! -L "$EN" ]] || { echo 'ERROR: unexpected EN site'; exit 1; }
grep -Fq 'root * /opt/hs2/edge/sites/systemlog' /etc/caddy/Caddyfile || { echo 'ERROR: Caddy web root differs'; exit 1; }

current_cs=$(git hash-object "$CS")
current_en=$(git hash-object "$EN")
if [[ "$current_cs" == "$NEW_CS" && "$current_en" == "$NEW_EN" ]]; then
  echo 'ALREADY DEPLOYED: exact SystemLog 1.0 CS/EN hashes'; exit 0
fi
[[ "$current_cs" == "$OLD_CS" && "$current_en" == "$OLD_EN" ]] || {
  echo 'ERROR: existing public pages differ from reviewed baseline; no changes made'
  echo "Observed CZ Git blob: $current_cs"
  echo "Observed EN Git blob: $current_en"
  exit 1
}

stage=$(mktemp -d /var/tmp/systemlog-public.XXXXXXXX)
new_cs= new_en= backup= changed=0
finish(){
  rc=$?
  trap - EXIT
  if [[ "$changed" == 1 && -n "$backup" ]]; then
    echo 'ERROR: verification failed, restoring previous CZ/EN pages'
    install -m 0644 "$backup/index.html" "$CS"
    install -m 0644 "$backup/en-index.html" "$EN"
    chown --reference="$backup/index.html" "$CS" || true
    chown --reference="$backup/en-index.html" "$EN" || true
    [[ "$(git hash-object "$CS")" == "$OLD_CS" && "$(git hash-object "$EN")" == "$OLD_EN" ]] && echo 'ROLLBACK: VERIFIED' || echo 'ROLLBACK: NEEDS MANUAL REVIEW'
  fi
  [[ -n "$new_cs" ]] && rm -f -- "$new_cs"
  [[ -n "$new_en" ]] && rm -f -- "$new_en"
  rm -rf -- "$stage"
  exit "$rc"
}
trap finish EXIT

curl -fsSL --retry 2 --connect-timeout 8 --max-time 45 -o "$stage/cs" "$BASE/index.html"
curl -fsSL --retry 2 --connect-timeout 8 --max-time 45 -o "$stage/en" "$BASE/en/index.html"
[[ "$(git hash-object "$stage/cs")" == "$NEW_CS" && "$(git hash-object "$stage/en")" == "$NEW_EN" ]] || { echo 'ERROR: pinned GitHub source hash mismatch'; exit 1; }
for match in 'lang="cs"' 'BICHEZ Importer' 'Můj Šatník' 'certifikace'; do grep -Fq "$match" "$stage/cs" || { echo "ERROR: CZ content gate: $match"; exit 1; }; done
for match in 'lang="en"' 'BICHEZ Importer' 'Můj Šatník' 'Qualifications'; do grep -Fq "$match" "$stage/en" || { echo "ERROR: EN content gate: $match"; exit 1; }; done

install -d -m 0700 "$BACKUPS"
backup="$BACKUPS/release-$(date -u +%Y%m%dT%H%M%SZ)"
install -d -m 0700 "$backup"
cp -p "$CS" "$backup/index.html"
cp -p "$EN" "$backup/en-index.html"

new_cs=$(mktemp "$SITE/.public-cs.XXXXXXXX")
new_en=$(mktemp "$SITE/en/.public-en.XXXXXXXX")
cp "$stage/cs" "$new_cs"
cp "$stage/en" "$new_en"
chown --reference="$CS" "$new_cs"
chown --reference="$EN" "$new_en"
chmod --reference="$CS" "$new_cs"
chmod --reference="$EN" "$new_en"
changed=1
mv -f -- "$new_en" "$EN"; new_en=
mv -f -- "$new_cs" "$CS"; new_cs=
[[ "$(git hash-object "$CS")" == "$NEW_CS" && "$(git hash-object "$EN")" == "$NEW_EN" ]] || { echo 'ERROR: deployed file hash mismatch'; exit 1; }
# Fetch completely before searching. Avoid curl | grep -q under pipefail,
# because grep may close the pipe early and make a successful curl look failed.
verify_origin(){
  local route="$1" marker="$2" output="$3"
  curl -kfsS --noproxy '*' --max-time 15 --resolve systemlog.icu:443:127.0.0.1 -o "$output" "https://systemlog.icu$route"
  grep -Fq "$marker" "$output"
}
verify_origin / 'Stavím věci' "$stage/origin-cs.html"
verify_origin /en/ 'I build things' "$stage/origin-en.html"
changed=0
printf '%s\n' 'DEPLOY: PASS — public CZ/EN origin verified' "BACKUP: $backup" 'CZ: https://systemlog.icu/' 'EN: https://systemlog.icu/en/' 'PRIVATE JOURNAL: not deployed; requires access gate first' 'NOTE: Cloudflare may still challenge public automated clients.'
