from pathlib import Path
from zipfile import ZipFile
import hashlib, io, json, os, grp, socket, tempfile, shutil, subprocess, sys

archive = Path('/root/systemlog-1.0-private-journal.zip')
base = Path('/var/lib/systemlog-private')
target = base / 'history'
expected = '6b95e9ae809b4c25021a0368a74be4b39bd2ce2b9257e46a666ef341e3e2413c'

def require(ok, why):
    if not ok:
        raise SystemExit('STOP: ' + why)

def http(route):
    args = ['curl', '-ksS', '--noproxy', '*', '--max-time', '15', '--resolve',
            'systemlog.icu:443:127.0.0.1', '-o', '/dev/null', '-w', '%{http_code}',
            'https://systemlog.icu' + route]
    return subprocess.check_output(args, text=True).strip()

require(os.geteuid() == 0 and socket.gethostname() == 'hs2-itachi-core', 'Only root on HS2')
require(archive.is_file() and not archive.is_symlink(), 'Archive missing or symlink')
raw = archive.read_bytes()
require(hashlib.sha256(raw).hexdigest() == expected, 'ZIP hash mismatch')
with ZipFile(io.BytesIO(raw)) as z:
    require(z.testzip() is None, 'ZIP integrity failure')
    require(set(z.namelist()) == {'index.html', 'journal.json', 'README-SECURITY.md', 'JOURNAL-EDITING.md'}, 'Unexpected ZIP entries')
    html = z.read('index.html')
    data = z.read('journal.json')
    parsed = json.loads(data)
    require(isinstance(parsed, dict) and isinstance(parsed.get('entries'), list) and len(parsed['entries']) == 17, 'Unexpected journal schema')
    require(b'<title>SystemLog' in html and b'<html lang="cs"' in html, 'Unexpected journal HTML')
require(base.is_dir() and target.is_dir() and not base.is_symlink() and not target.is_symlink(), 'Unexpected private directory')
require(not any(target.iterdir()), 'History directory not empty: refusing overwrite')
for path, digest in [
    ('/opt/hs2/edge/sites/systemlog/index.html', '93ed6dcfa53d40c798c334405437bf41ef8c68fb'),
    ('/opt/hs2/edge/sites/systemlog/en/index.html', '0bba58aa766930ff8f37130f53376a83792580bc')
]:
    require(subprocess.check_output(['git', 'hash-object', path], text=True).strip() == digest,
            'Public CV source changed: ' + path)
for p in ['/history', '/history/', '/history/index.html', '/history/journal.json']:
    require(http(p) == '401', 'Authentication gate not active at ' + p)
for p in ['/', '/en/']:
    require(http(p) == '200', 'Public page failed at ' + p)
print('PRECHECK: PASS - ZIP, empty private directory, access gate, public CV')

stage = Path(tempfile.mkdtemp(prefix='.history-stage-', dir=base))
gid = grp.getgrnam('caddy').gr_gid
try:
    os.chown(stage, 0, gid)
    os.chmod(stage, 0o750)
    for name, content in [('index.html', html), ('journal.json', data)]:
        output = stage / name
        with output.open('xb') as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
        os.chown(output, 0, gid)
        os.chmod(output, 0o640)
    require(not any(target.iterdir()), 'History directory changed before promotion')
    os.replace(stage, target)  # atomic replacement of existing, empty directory
finally:
    if stage.exists():
        shutil.rmtree(stage)

try:
    for p in ['/history', '/history/', '/history/index.html', '/history/journal.json']:
        require(http(p) == '401', 'Postinstall unauthenticated route not gated: ' + p)
    for p in ['/', '/en/']:
        require(http(p) == '200', 'Postinstall public page failed: ' + p)
except BaseException:
    # Remove content from the served path immediately. Preserve archive in /root.
    quarantine = Path(tempfile.mkdtemp(prefix='.history-quarantine-', dir=base))
    os.rmdir(quarantine)
    os.replace(target, quarantine)
    target.mkdir(mode=0o750)
    os.chown(target, 0, gid)
    print('ROLLBACK: protected files taken out of the served path', file=sys.stderr)
    raise
print('INSTALL: PASS - protected HTML and JSON installed outside public webroot')
print('ANONYMOUS: PASS - all history paths HTTP 401')
print('PUBLIC: PASS - CZ and EN HTTP 200')
print('NEXT: Open https://systemlog.icu/history/ and authenticate as journal')
