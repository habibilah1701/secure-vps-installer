#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y rclone
install -d -m 0700 /root/.config/rclone
cat >/root/.config/rclone/README-HABIBILLAH.txt <<'EOF'
Configure your own rclone remote on this VPS:
  rclone config
Then test it:
  rclone listremotes
No shared token, password, email, or remote config is shipped by HABIBILLAH.
EOF
chmod 0600 /root/.config/rclone/README-HABIBILLAH.txt
install -d -m 0755 /usr/local/share/habibillah
cat >/usr/local/share/habibillah/backup-status <<'EOF2'
#!/usr/bin/env bash
if [[ -s /root/.config/rclone/rclone.conf ]]; then
  echo 'rclone is configured for this VPS.'
  rclone listremotes
else
  echo 'Backup is not configured. Run: rclone config'
fi
EOF2
chmod 0755 /usr/local/share/habibillah/backup-status
ln -sfn /usr/local/share/habibillah/backup-status /usr/bin/backup-status
