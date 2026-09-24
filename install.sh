#!/usr/bin/env bash
# Secure VPS Installer: package-managed, auditable, and opt-in.
set -Eeuo pipefail
IFS=$'\n\t'

PROFILE="baseline"
DRY_RUN=0
SSH_PORTS="22"
SKIP_UPGRADE=0
LOG_FILE="/var/log/secure-vps-installer.log"

usage() {
  cat <<'EOF'
Usage: sudo ./install.sh [options]

Options:
  --profile baseline|vpn|full   Components to install (default: baseline)
  --ssh-ports LIST              SSH ports, comma-separated (default: 22)
  --skip-upgrade                Skip apt-get upgrade (not recommended)
  --dry-run                     Show actions without changing the system
  -h, --help                    Show this help

Examples:
  sudo ./install.sh --dry-run --profile baseline
  sudo ./install.sh --profile full --ssh-ports 22,3369,2269,169,99

Deliberately excluded: PPTP, SSR, OHP, SlowDNS, and remote curl|bash installers.
Legacy services are obsolete or cannot be safely pinned and audited here.
EOF
}

while (($#)); do
  case "$1" in
    --profile) (($# >= 2)) || { echo "--profile requires a value" >&2; exit 2; }; PROFILE="$2"; shift 2 ;;
    --ssh-ports) (($# >= 2)) || { echo "--ssh-ports requires a value" >&2; exit 2; }; SSH_PORTS="$2"; shift 2 ;;
    --skip-upgrade) SKIP_UPGRADE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ $PROFILE =~ ^(baseline|vpn|full)$ ]] || { echo "Invalid profile: $PROFILE" >&2; exit 2; }
[[ $SSH_PORTS =~ ^[0-9]+(,[0-9]+)*$ ]] || { echo "Invalid SSH port list: $SSH_PORTS" >&2; exit 2; }
IFS=',' read -ra _ports <<< "$SSH_PORTS"
for _port in "${_ports[@]}"; do
  (( _port >= 1 && _port <= 65535 )) || { echo "Invalid SSH port: $_port" >&2; exit 2; }
done

(( EUID == 0 )) || { echo "Run as root: sudo $0" >&2; exit 1; }
command -v systemd-detect-virt >/dev/null || { echo "systemd is required" >&2; exit 1; }
[[ -r /etc/os-release ]] || { echo "Cannot identify operating system" >&2; exit 1; }
. /etc/os-release
case "${ID:-}" in ubuntu|debian) ;; *) echo "Supported OS: Ubuntu or Debian" >&2; exit 1 ;; esac
case "${VERSION_ID:-}" in 18.04|20.04|22.04|24.04|9|10|11|12) ;; *) echo "Unsupported OS version: ${VERSION_ID:-unknown}" >&2; exit 1 ;; esac

if (( DRY_RUN )); then
  LOG_FILE="/tmp/secure-vps-installer.log"
else
  install -d -m 0750 /var/log
  touch "$LOG_FILE" && chmod 0600 "$LOG_FILE"
fi
log() { printf '[%s] %s\n' "$(date -Is)" "$*" | tee -a "$LOG_FILE"; }
die() { log "ERROR: $*"; exit 1; }
run() { if (( DRY_RUN )); then printf '+'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }

log "Starting profile=$PROFILE os=${ID}:${VERSION_ID} ssh_ports=$SSH_PORTS dry_run=$DRY_RUN"
export DEBIAN_FRONTEND=noninteractive
run apt-get update
if (( ! SKIP_UPGRADE )); then
  run apt-get upgrade -y
else
  log "Skipping apt-get upgrade by request"
fi
run apt-get install -y --no-install-recommends ca-certificates curl unzip jq nftables fail2ban openssh-server wireguard-tools nginx

if [[ "$PROFILE" == vpn || "$PROFILE" == full ]]; then
  run apt-get install -y --no-install-recommends openvpn strongswan xl2tpd shadowsocks-libev || log "Some optional VPN packages are unavailable; continuing"
fi
if [[ "$PROFILE" == full ]]; then
  run apt-get install -y --no-install-recommends certbot python3-certbot-nginx || log "Certbot unavailable; install separately if needed"
fi

if (( ! DRY_RUN )); then
  install -d -m 0755 /etc/ssh/sshd_config.d
  cp -a /etc/ssh/sshd_config "/etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)"
  {
    echo '# Managed by secure-vps-installer; root login and password authentication are not enabled.'
    for _port in "${_ports[@]}"; do echo "Port $_port"; done
    echo 'PermitEmptyPasswords no'
    echo 'PermitRootLogin prohibit-password'
    echo 'PasswordAuthentication no'
    echo 'X11Forwarding no'
    echo 'AllowTcpForwarding yes'
    echo 'MaxAuthTries 5'
  } > /etc/ssh/sshd_config.d/99-secure-vps-installer.conf
  if ! sshd -t; then
    cp -a "$(ls -1t /etc/ssh/sshd_config.backup.* | head -1)" /etc/ssh/sshd_config
    rm -f /etc/ssh/sshd_config.d/99-secure-vps-installer.conf
    die "sshd configuration validation failed; previous configuration restored"
  fi
  systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd || die "Could not start SSH"

  cat >/etc/fail2ban/jail.d/secure-vps-installer.local <<'EOF'
[sshd]
enabled = true
port = ssh
maxretry = 5
findtime = 10m
bantime = 1h
EOF
  systemctl enable --now fail2ban
  systemctl enable --now nftables
  systemctl enable --now nginx
  log "Services enabled: ssh, fail2ban, nftables, nginx"
fi

cat <<'EOF'

Installation plan completed.

Security notes:
- No password, private key, PAM file, remote config, or hard-coded credential was installed.
- PasswordAuthentication is disabled and root login is restricted to keys.
- Review the SSH drop-in and provider firewall before disconnecting.
- Use a provider console/snapshot before changing SSH or firewall settings.
- PPTP, SSR, OHP, and SlowDNS are intentionally not installed.
EOF
log "Completed successfully"
