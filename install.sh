#!/usr/bin/env bash
# HABIBILLAH complete VPS installer. Installs the original feature set from vendored modules.
set -Eeuo pipefail
IFS=$'\n\t'

PROFILE="full"
NO_MENU=0
SKIP_UPGRADE=0
DRY_RUN=0
VENDOR_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)/vendor"
REPO_TARBALL="https://codeload.github.com/habibilah1701/secure-vps-installer/tar.gz/main"
LOG_FILE="/var/log/habibillah-installer.log"

usage() {
  cat <<'EOF'
HABIBILLAH VPS INSTALLER

Usage: sudo ./setup.sh [options]
  --profile full       Install complete original feature set (default)
  --skip-upgrade       Skip apt upgrade
  --dry-run            Validate and display the complete installation plan only
  --no-menu             Install services without opening the menu
  -h, --help            Show this help

The complete profile includes SSH/OpenVPN, L2TP, PPTP, SSTP, WireGuard,
Shadowsocks, SSR, Xray VMess/VLESS/Trojan/gRPC, Trojan-Go, WebSocket, OHP,
SlowDNS, backup/restore, account expiry tools, and the HABIBILLAH menu.
EOF
}
while (($#)); do
  case "$1" in
    --profile) PROFILE="${2:?missing profile}"; shift 2 ;;
    --skip-upgrade) SKIP_UPGRADE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-menu) NO_MENU=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
if (( DRY_RUN )); then
  cat <<'PLAN'
HABIBILLAH COMPLETE INSTALLATION PLAN
- apt update and apt upgrade
- install dependencies including screen, SSH, VPN, Xray, WebSocket, and backup tools
- generate unique DH parameters and self-signed certificate for this VPS
- install vendored original service modules without vpsroot/addhost URL overwrite
- install 60-option centered HABIBILLAH menu
- create per-server runtime state; no shared credentials
PLAN
  exit 0
fi
(( EUID == 0 )) || { echo 'Run as root: sudo ./setup.sh' >&2; exit 1; }
[[ -r /etc/os-release ]] || { echo 'Cannot identify OS' >&2; exit 1; }
. /etc/os-release
case "${ID:-}" in ubuntu|debian) ;; *) echo 'Supported OS: Ubuntu or Debian' >&2; exit 1 ;; esac

install -d -m 0750 /var/log
: > "$LOG_FILE"; chmod 0600 "$LOG_FILE"
log() { printf '[%s] %s\n' "$(date -Is)" "$*" | tee -a "$LOG_FILE"; }
fail() { log "FAILED: $*"; exit 1; }
apt_retry() {
  local _label="$1"; shift
  local _attempt
  for _attempt in 1 2 3; do
    log "$_label attempt $_attempt/3"
    if "$@" >>"$LOG_FILE" 2>&1; then return 0; fi
    sleep 5
  done
  log "$_label failed; last apt output:"
  tail -80 "$LOG_FILE" >&2 || true
  return 1
}
optional_install() {
  local pkg
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      apt-get install -y --no-install-recommends "$pkg" >>"$LOG_FILE" 2>&1 || log "Optional package failed: $pkg"
    else
      log "Package unavailable on ${ID}:${VERSION_ID}: $pkg"
    fi
  done
}

log "HABIBILLAH installer starting on ${ID}:${VERSION_ID}"
export DEBIAN_FRONTEND=noninteractive
apt_retry 'apt update' apt-get update || fail 'apt update failed; inspect /var/log/habibillah-installer.log'
if (( ! SKIP_UPGRADE )); then apt_retry 'apt upgrade' apt-get upgrade -y || fail 'apt upgrade failed; inspect /var/log/habibillah-installer.log'; fi
optional_install ca-certificates bzip2 gzip coreutils screen curl wget unzip zip jq git sed nano bc \
  gnupg gnupg1 dirmngr apt-transport-https build-essential gcc g++ make cmake ruby \
  python3 python3-pip rsyslog net-tools lsof iftop htop neofetch dos2unix \
  libxml-parser-perl libsqlite3-dev libz-dev libreadline-dev zlib1g-dev libssl-dev \
  nginx php php-fpm php-cli php-mysql dropbear squid3 sslh openvpn strongswan xl2tpd \
  shadowsocks-libev wireguard-tools fail2ban certbot python3-certbot-nginx openssl

# Generate per-server cryptographic material; never reuse public repository keys.
install -d -m 0700 /etc/ssl/private /etc/ssl/certs
if [[ ! -s /etc/ssl/private/habibillah-dhparam.pem ]]; then
  log 'Generating unique DH parameters for this VPS (may take a while)'
  openssl dhparam -out /etc/ssl/private/habibillah-dhparam.pem 2048 >>"$LOG_FILE" 2>&1 || fail 'DH parameter generation failed'
  chmod 0600 /etc/ssl/private/habibillah-dhparam.pem
fi
ln -sfn /etc/ssl/private/habibillah-dhparam.pem /root/dh2048.pem
if [[ ! -s /etc/ssl/private/habibillah.key || ! -s /etc/ssl/certs/habibillah.crt ]]; then
  openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
    -keyout /etc/ssl/private/habibillah.key \
    -out /etc/ssl/certs/habibillah.crt \
    -subj "/CN=$(hostname -f 2>/dev/null || hostname)" >>"$LOG_FILE" 2>&1 || fail 'local certificate generation failed'
  chmod 0600 /etc/ssl/private/habibillah.key
  chmod 0644 /etc/ssl/certs/habibillah.crt
fi

if [[ ! -d "$VENDOR_DIR" ]]; then
  tmp="$(mktemp -d /tmp/habibillah-vendor.XXXXXX)"
  trap 'rm -rf "$tmp"' EXIT
  curl --proto '=https' --tlsv1.2 -fsSL "$REPO_TARBALL" -o "$tmp/repo.tgz" || fail 'could not download vendor package'
  tar -xzf "$tmp/repo.tgz" -C "$tmp" || fail 'could not extract vendor package'
  VENDOR_DIR="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d -name 'secure-vps-installer-*' -print -quit)/vendor"
fi
[[ -x "$VENDOR_DIR/setup.sh" || -f "$VENDOR_DIR/setup.sh" ]] || fail "vendor setup not found: $VENDOR_DIR"

# Remove known upstream credential artifacts even if an old archive contains them.
rm -f "$VENDOR_DIR/backup/rclone.conf" "$VENDOR_DIR/ssh/dh2048.pem" 2>/dev/null || true
chmod +x "$VENDOR_DIR/setup.sh" "$VENDOR_DIR"/**/*.sh 2>/dev/null || true
log 'Running complete feature installer; individual module failures are recorded in the log.'
if ! bash "$VENDOR_DIR/setup.sh" >>"$LOG_FILE" 2>&1; then
  log 'Vendor setup returned an error; continuing to install menu, but review the log before using services.'
fi

install -d -m 0755 /usr/local/share/habibillah /usr/bin
if [[ -f "$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)/menu.sh" ]]; then
  install -m 0755 "$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)/menu.sh" /usr/local/share/habibillah/menu
else
  curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/menu.sh -o /usr/local/share/habibillah/menu
  chmod 0755 /usr/local/share/habibillah/menu
fi
ln -sfn /usr/local/share/habibillah/menu /usr/bin/menu
cat >/etc/profile.d/habibillah-menu.sh <<'EOF'
# Open HABIBILLAH menu for interactive login shells only.
if [[ $- == *i* && -x /usr/bin/menu && -z "${HABIBILLAH_MENU_ACTIVE:-}" ]]; then
  export HABIBILLAH_MENU_ACTIVE=1
  /usr/bin/menu
  unset HABIBILLAH_MENU_ACTIVE
fi
EOF
chmod 0644 /etc/profile.d/habibillah-menu.sh

log 'Installer completed; menu installed at /usr/bin/menu.'
cat <<'EOF'

============================================================
 HABIBILLAH VPS INSTALLATION FINISHED
 Pembuat : Habibillah
 WhatsApp: 081374452477
 Menu    : type menu
 Log     : /var/log/habibillah-installer.log
============================================================
EOF
if (( ! NO_MENU )) && [[ -t 0 ]]; then exec /usr/bin/menu; fi
