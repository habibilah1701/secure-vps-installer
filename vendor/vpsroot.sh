#!/usr/bin/env bash
set -Eeuo pipefail
# Local, validated SSH setup. Never downloads or overwrites sshd_config from a URL.
install -d -m 0755 /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/90-habibillah-ports.conf <<'EOC'
# Managed by HABIBILLAH installer; root remains key-only.
Port 22
Port 3369
Port 2269
Port 169
Port 99
PermitEmptyPasswords no
PermitRootLogin prohibit-password
EOC
sshd -t
systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null || true
