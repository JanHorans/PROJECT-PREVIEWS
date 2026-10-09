#!/usr/bin/env bash
# HS2 SystemLog: establish and verify authentication for EMPTY private history.
# Does NOT publish journal files, change Cloudflare, or change public CV pages.
set -Eeuo pipefail
umask 077

CONFIG=/etc/caddy/Caddyfile
SITE=/opt/hs2/edge/sites/systemlog
PRIVATE=/var/lib/systemlog-private/history
BACKUP_DIR=/var/backups/systemlog-history
USER_NAME=journal
EXPECTED_CS=93ed6dcfa53d40c798c334405437bf41ef8c68fb
EXPECTED_EN=0bba58aa766930ff8f37130f53376a83792580bc

[[ ${EUID:-$(id -u)} -eq 0 ]] || { echo 'ERROR: Run with sudo on HS2'; exit 1; }
[[ "$(hostname)" == hs2-itachi-core ]] || { echo 'ERROR: Host is not hs2-itachi-core'; exit 1; }
[[ -f "$CONFIG" && ! -L "$CONFIG" ]] || { echo 'ERROR: Caddyfile is absent/symlink'; exit 1; }
[[ -f "$SITE/index.html" && -f "$SITE/en/index.html" ]] || { echo 'ERROR: Public pages missing'; exit 1; }
[[ "$(git hash-object "$SITE/index.html")" == "$EXPECTED_CS" ]] || { echo 'ERROR: Unexpected public CZ baseline'; exit 1; }
[[ "$(git hash-object "$SITE/en/index.html")" == "$EXPECTED_EN" ]] || { echo 'ERROR: Unexpected public EN baseline'; exit 1; }
systemctl is-active --quiet caddy || { echo 'ERROR: Caddy not running'; exit 1; }
for tool in python3 caddy git sha256sum curl systemctl mktemp openssl; do
  command -v "$tool" >/dev/null || { echo "ERROR: $tool missing"; exit 1; }
done
[[ ! -e "$PRIVATE" && ! -L "$PRIVATE" ]] || { echo 'ERROR: History dir already exists; no overwrite'; exit 1; }
[[ ! -e /opt/hs2/edge/sites/systemlog/history && ! -L /opt/hs2/edge/sites/systemlog/history ]] || { echo 'ERROR: Public history path exists'; exit 1; }

# No secrets are printed or written to shell history / disk.
[[ -t 0 ]] || { echo 'ERROR: Interactive terminal needed for password entry'; exit 1; }
echo 'Set a new password for the private SystemLog journal (min 16 chars).'
echo 'Do not send the password to ChatGPT. Save it in your password manager.'
IFS= read -r -s -p 'Password: ' password; printf '\n'
IFS= read -r -s -p 'Repeat password: ' confirm; printf '\n'
[[ "$password" == "$confirm" && ${#password} -ge 16 ]] || { echo 'ERROR: Passwords differ or password too short'; exit 1; }
unset confirm
# Caddy 2.6.2 prompts twice when --plaintext is omitted; feed both lines via stdin.
# Never place the password on the command line or write it to disk.
hash=$(printf '%s\n%s\n' "$password" "$password" | caddy hash-password)
unset password
[[ "$hash" =~ ^\$2[aby]\$ ]] || { echo 'ERROR: Unexpected Caddy password hash'; exit 1; }

old_sha=$(sha256sum "$CONFIG" | awk '{print $1}')
stage=$(mktemp /etc/caddy/.Caddyfile.systemlog-private.XXXXXXXX)
backup=''
applied=0
ok=0
finish() {
  local rc=$?
  trap - EXIT
  if [[ "$applied" == 1 && "$ok" != 1 ]]; then
    echo 'ERROR: Rolling back the Caddyfile'
    cp -p "$backup" "$CONFIG"
    systemctl reload caddy && echo 'ROLLBACK: Caddy config restored' || echo 'ROLLBACK: Caddy reload failed, manual attention needed'
  fi
  rm -f -- "$stage"
  exit "$rc"
}
trap finish EXIT

python3 - "$CONFIG" "$stage" "$hash" <<'PY'
import pathlib, sys
source, target, hashed = map(str, sys.argv[1:4])
lines = pathlib.Path(source).read_text(encoding='utf-8').splitlines(keepends=True)
# Find exactly one SystemLog site header followed by the reviewed static root.
headers = [i for i, s in enumerate(lines) if 'systemlog.icu' in s and '{' in s and not s.lstrip().startswith('#') and not s.lstrip().startswith('tls') and not s.lstrip().startswith('reverse_proxy')]
candidates = []
for i in headers:
    depth = 0
    for j in range(i, len(lines)):
        # Current site is simple; enforce no unrecognised nested blocks.
        depth += lines[j].count('{') - lines[j].count('}')
        if depth == 0:
            chunk = lines[i:j+1]
            if any(s.strip() == 'root * /opt/hs2/edge/sites/systemlog' for s in chunk):
                candidates.append((i,j,chunk))
            break
if len(candidates) != 1:
    raise SystemExit('ERROR: Could not uniquely identify SystemLog Caddy site')
start,end,block=candidates[0]
if any('history' in s.lower() or 'basicauth' in s or 'basic_auth' in s for s in block):
    raise SystemExit('ERROR: Existing history/auth rules in this site; stop')
if sum(s.strip() == 'file_server' for s in block) != 1:
    raise SystemExit('ERROR: Unexpected file_server config; stop')
# Insert before closing brace. Caddy executes named handle with specific matcher
# before the default file_server, and basicauth guards all private routes.
addition = (
    '    @privateHistory path /history /history/*\n'
    '    handle @privateHistory {\n'
    '        basicauth {\n'
    f'            journal {hashed}\n'
    '        }\n'
    '        uri strip_prefix /history\n'
    '        root * /var/lib/systemlog-private/history\n'
    '        file_server\n'
    '    }\n'
)
lines.insert(end, addition)
pathlib.Path(target).write_text(''.join(lines), encoding='utf-8')
PY
chown --reference="$CONFIG" "$stage"
chmod --reference="$CONFIG" "$stage"
caddy validate --config "$stage" --adapter caddyfile >/dev/null 2>&1 || { echo 'ERROR: Caddy rejected staged config; no changes made'; exit 1; }
[[ "$(sha256sum "$CONFIG" | awk '{print $1}')" == "$old_sha" ]] || { echo 'ERROR: Caddyfile changed meanwhile'; exit 1; }

install -d -m 0700 "$BACKUP_DIR"
backup="$BACKUP_DIR/Caddyfile-$(date -u +%Y%m%dT%H%M%SZ)"
cp -p "$CONFIG" "$backup"
install -d -o root -g caddy -m 0750 /var/lib/systemlog-private
install -d -o root -g caddy -m 0750 "$PRIVATE"

applied=1
mv -f -- "$stage" "$CONFIG"
systemctl reload caddy
systemctl is-active --quiet caddy

status() {
  curl -ksS --noproxy '*' --max-time 15 --resolve systemlog.icu:443:127.0.0.1 -o /dev/null -w '%{http_code}' "https://systemlog.icu$1"
}
for path in /history /history/ /history/index.html /history/journal.json; do
  got=$(status "$path")
  [[ "$got" == 401 ]] || { echo "ERROR: $path should require login but returned $got"; exit 1; }
done
for path in / /en/; do
  got=$(status "$path")
  [[ "$got" == 200 ]] || { echo "ERROR: Public $path expected 200, got $got"; exit 1; }
done
ok=1
printf '%s\n' 'GATE: PASS — unauthenticated history paths return HTTP 401' 'PUBLIC: PASS — CZ and EN still return HTTP 200' "CONFIG BACKUP: $backup" "HISTORY ROOT: $PRIVATE (empty, outside public web root)" 'JOURNAL: not deployed' 'USERNAME: journal' 'PASSWORD: not printed; use the one you just entered'
