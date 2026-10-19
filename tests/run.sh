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

assert_contains "$TIMER" 'OnBootSec=10min'
assert_contains "$TIMER" 'OnUnitActiveSec=4h'
assert_contains "$TIMER" 'RandomizedDelaySec=5min'
assert_contains "$TIMER" 'Persistent=true'
assert_contains "$SCRIPT" 'sync_packagekit'
assert_contains "$SERVICE" 'IOSchedulingClass=idle'
assert_contains "$SERVICE" 'CPUWeight=10'
assert_contains "$SERVICE" 'User=root'
assert_contains "$SERVICE" 'Environment=LINUX_AUTO_UPDATE_ENABLE_SNAP=1'
assert_contains "$SERVICE" 'Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
assert_contains "$ROOT/install.sh" '[[ "$state" == "enabled" || "$state" == "enabled-runtime" ]]'
assert_absent "$ROOT/install.sh" 'is-enabled --quiet dnf-automatic.timer'

"$SCRIPT" status >/dev/null

mkdir -p "$TEMP_DIR/bin"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\\n" "$*" >> "$MOCK_LOG"' 'exit "${MOCK_EXIT:-0}"' > "$TEMP_DIR/bin/snap"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\\n" "$*" >> "$MOCK_LOG"' 'exit "${MOCK_EXIT:-0}"' > "$TEMP_DIR/bin/fwupdmgr"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\\n" "$*" >> "$MOCK_LOG"' 'exit "${MOCK_EXIT:-0}"' > "$TEMP_DIR/bin/pkcon"
chmod 0755 "$TEMP_DIR/bin/snap" "$TEMP_DIR/bin/fwupdmgr" "$TEMP_DIR/bin/pkcon"

MOCK_LOG="$TEMP_DIR/pkcon.log" PATH="$TEMP_DIR/bin:$PATH" \
  bash -c 'source "$1"; sync_packagekit' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/pkcon.log" 'refresh force -c 1'
assert_absent "$TEMP_DIR/pkcon.log" '-c -1'

MOCK_LOG="$TEMP_DIR/snap.log" PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_SNAP=1 \
  bash -c 'source "$1"; update_snap' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/snap.log" 'refresh'

MOCK_LOG="$TEMP_DIR/snap-default.log" PATH="$TEMP_DIR/bin:$PATH" \
  bash -c 'source "$1"; update_snap' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/snap-default.log" 'refresh'

MOCK_LOG="$TEMP_DIR/fwupd.log" PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_FWUPD=1 \
  bash -c 'source "$1"; update_firmware' _ "$SCRIPT" >/dev/null
assert_contains "$TEMP_DIR/fwupd.log" 'refresh'
assert_contains "$TEMP_DIR/fwupd.log" 'update -y --no-unreported-check'

# Tester que fwupd exit code 2 (rien à mettre à jour) est bien traité comme un succès (OK)
MOCK_LOG="$TEMP_DIR/fwupd2.log" MOCK_EXIT=2 PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_FWUPD=1 \
  bash -c 'source "$1"; update_firmware' _ "$SCRIPT" >/dev/null

set +e
MOCK_LOG="$TEMP_DIR/failure.log" MOCK_EXIT=23 PATH="$TEMP_DIR/bin:$PATH" LINUX_AUTO_UPDATE_ENABLE_SNAP=1 \
  bash -c 'source "$1"; update_snap' _ "$SCRIPT" >/dev/null
failure_rc=$?
set -e
[[ "$failure_rc" -eq 23 ]] || fail "Le code d’échec Snap attendu est 23, reçu : $failure_rc"

printf '✓ Tous les tests sont passés.\n'
