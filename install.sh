#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Lancez ce script avec sudo."; exit 1; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install -Dm755 "$ROOT/bin/linux-auto-update" /usr/local/bin/linux-auto-update
install -Dm644 "$ROOT/systemd/linux-auto-update.service" /etc/systemd/system/linux-auto-update.service
install -Dm644 "$ROOT/systemd/linux-auto-update.timer" /etc/systemd/system/linux-auto-update.timer
systemctl daemon-reload
systemctl enable --now linux-auto-update.timer
systemctl restart linux-auto-update.timer
if systemctl is-enabled --quiet dnf5-automatic.timer 2>/dev/null || systemctl is-enabled --quiet dnf-automatic.timer 2>/dev/null; then
  echo "Attention : un autre service de mise à jour DNF est actif. Désactivez-le pour éviter les chevauchements."
fi
echo "Installation terminée et timer linux-auto-update activé."
