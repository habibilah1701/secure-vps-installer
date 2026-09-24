#!/usr/bin/env bash
set -Eeuo pipefail
# Per-server autosetting hook; intentionally does not reboot or alter PAM.
systemctl daemon-reload 2>/dev/null || true
for svc in ssh sshd fail2ban nginx; do
  systemctl try-reload-or-restart "$svc" 2>/dev/null || true
done
