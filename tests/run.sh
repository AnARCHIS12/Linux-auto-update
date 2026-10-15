#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPT="$ROOT/bin/linux-auto-update"
readonly SERVICE="$ROOT/systemd/linux-auto-update.service"
readonly TIMER="$ROOT/systemd/linux-auto-update.timer"
TEMP_DIR="$(mktemp -d)"
trap 'rm -r -- "$TEMP_DIR"' EXIT

fail() {
  printf '✕ %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local file="$1" pattern="$2"
  grep -Fq -- "$pattern" "$file" || fail "$file ne contient pas : $pattern"
}

assert_absent() {
  local file="$1" pattern="$2"
  if grep -Fq -- "$pattern" "$file"; then
    fail "$file contient encore : $pattern"
  fi
}

bash -n "$SCRIPT" "$ROOT/install.sh" "$0"
systemd-analyze verify "$SERVICE" "$TIMER" >/dev/null
systemd-analyze calendar '*-*-* 03:00:00' >/dev/null

assert_contains "$TIMER" 'OnCalendar=*-*-* 03:00:00'
assert_contains "$TIMER" 'RandomizedDelaySec=3h'
assert_contains "$TIMER" 'Persistent=true'
assert_absent "$TIMER" 'OnUnitActiveSec='
assert_absent "$SCRIPT" 'sync_packagekit'
assert_absent "$SCRIPT" 'fwupdmgr refresh --force'
assert_contains "$SERVICE" 'IOSchedulingClass=idle'
assert_contains "$SERVICE" 'CPUWeight=10'
assert_contains "$SERVICE" 'User=root'
assert_contains "$SERVICE" 'Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

"$SCRIPT" status >/dev/null

mkdir -p "$TEMP_DIR/bin"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\\n" "$*" >> "$MOCK_LOG"' 'exit "${MOCK_EXIT:-0}"' > "$TEMP_DIR/bin/snap"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\\n" "$*" >> "$MOCK_LOG"' 'exit "${MOCK_EXIT:-0}"' > "$TEMP_DIR/bin/fwupdmgr"
chmod 0755 "$TEMP_DIR/bin/snap" "$TEMP_DIR/bin/fwupdmgr"

MOCK_LOG="$TEMP_DIR/snap.log" PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_SNAP=1 \
  bash -c 'source "$1"; update_snap' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/snap.log" 'refresh'

MOCK_LOG="$TEMP_DIR/fwupd.log" PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_FWUPD=1 \
  bash -c 'source "$1"; update_firmware' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/fwupd.log" 'refresh'
assert_contains "$TEMP_DIR/fwupd.log" 'update -y --no-unreported-check'
assert_absent "$TEMP_DIR/fwupd.log" '--force'

set +e
MOCK_LOG="$TEMP_DIR/failure.log" MOCK_EXIT=23 PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_SNAP=1 \
  bash -c 'source "$1"; update_snap' _ "$SCRIPT" >/dev/null
failure_rc=$?
set -e
[[ "$failure_rc" -eq 23 ]] || fail "Le code d’échec Snap attendu est 23, reçu : $failure_rc"

printf '✓ Tous les tests sont passés.\n'
