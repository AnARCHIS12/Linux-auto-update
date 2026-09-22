#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Lancez ce script avec sudo."; exit 1; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install -Dm755 "$ROOT/bin/linux-auto-update" /usr/local/bin/linux-auto-update
install -Dm644 "$ROOT/systemd/linux-auto-update.service" /etc/systemd/system/linux-auto-update.service
install -Dm644 "$ROOT/systemd/linux-auto-update.timer" /etc/systemd/system/linux-auto-update.timer
systemctl daemon-reload
echo "Installation terminée."
echo "Activez le timer : sudo systemctl enable --now linux-auto-update.timer"
