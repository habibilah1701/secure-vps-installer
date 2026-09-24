#!/usr/bin/env bash
# Optional SSH user manager. Run on the target VPS as root.
set -Eeuo pipefail
IFS=$'\n\t'

USERNAME=""
DAYS=""
PASSWORD=""
ENABLE_PASSWORD_AUTH=0
GENERATED_PASSWORD=0

usage() {
  cat <<'EOF'
Usage:
  sudo ./ssh-user.sh --username NAME --days DAYS [options]

Options:
  --username NAME            New non-root Linux username
  --days DAYS                Account lifetime in days
  --password-stdin           Read password securely from stdin
  --enable-password-auth     Explicitly enable SSH password authentication
  -h, --help                 Show this help

If --password-stdin is omitted, a random temporary password is generated and
printed once. Change it immediately after first login.
EOF
}

while (($#)); do
  case "$1" in
    --username) (($# >= 2)) || { echo "--username requires a value" >&2; exit 2; }; USERNAME="$2"; shift 2 ;;
    --days) (($# >= 2)) || { echo "--days requires a value" >&2; exit 2; }; DAYS="$2"; shift 2 ;;
    --password-stdin) PASSWORD="__STDIN__"; shift ;;
    --enable-password-auth) ENABLE_PASSWORD_AUTH=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

(( EUID == 0 )) || { echo "Run as root" >&2; exit 1; }
[[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || { echo "Invalid username" >&2; exit 2; }
[[ "$USERNAME" != root ]] || { echo "Refusing to manage root" >&2; exit 2; }
[[ "$DAYS" =~ ^[1-9][0-9]{0,3}$ ]] || { echo "Days must be a positive integer" >&2; exit 2; }
(( DAYS <= 730 )) || { echo "Maximum account lifetime is 730 days" >&2; exit 2; }
command -v useradd >/dev/null || { echo "useradd is required" >&2; exit 1; }
command -v chage >/dev/null || { echo "chage is required" >&2; exit 1; }

if id "$USERNAME" >/dev/null 2>&1; then
  echo "User already exists: $USERNAME" >&2
  exit 1
fi

if [[ "$PASSWORD" == "__STDIN__" ]]; then
  IFS= read -r PASSWORD || true
  [[ -n "$PASSWORD" ]] || { echo "Password cannot be empty" >&2; exit 2; }
else
  PASSWORD="$(tr -dc 'A-Za-z0-9!@#$%^+=_' </dev/urandom | head -c 24 || true)"
  [[ ${#PASSWORD} -ge 20 ]] || { echo "Could not generate a strong password" >&2; exit 1; }
  GENERATED_PASSWORD=1
fi

useradd --create-home --shell /bin/bash "$USERNAME"
printf '%s:%s\n' "$USERNAME" "$PASSWORD" | chpasswd
EXPIRY="$(date -d "+${DAYS} days" +%Y-%m-%d)"
chage --expiredate "$EXPIRY" "$USERNAME"
passwd --maxdays "$DAYS" --mindays 0 --warndays 7 "$USERNAME" >/dev/null

if (( ENABLE_PASSWORD_AUTH )); then
  install -d -m 0755 /etc/ssh/sshd_config.d
  BACKUP="/etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)"
  cp -a /etc/ssh/sshd_config "$BACKUP"
  cat >/etc/ssh/sshd_config.d/98-ssh-password-users.conf <<'EOF'
# Explicitly enabled by ssh-user.sh. Root login remains key-only.
PasswordAuthentication yes
PermitRootLogin prohibit-password
PermitEmptyPasswords no
EOF
  if ! sshd -t; then
    rm -f /etc/ssh/sshd_config.d/98-ssh-password-users.conf
    cp -a "$BACKUP" /etc/ssh/sshd_config
    userdel --remove "$USERNAME" || true
    echo "sshd validation failed; user and SSH configuration rolled back" >&2
    exit 1
  fi
  systemctl reload ssh 2>/dev/null || systemctl reload sshd
fi

printf 'Created SSH user: %s\nExpires: %s\n' "$USERNAME" "$EXPIRY"
if (( ENABLE_PASSWORD_AUTH )); then
  echo 'PasswordAuthentication was explicitly enabled. Restrict access with a provider firewall and Fail2Ban.'
else
  echo 'PasswordAuthentication was not changed. Add an SSH public key to ~/.ssh/authorized_keys before login.'
fi
if (( GENERATED_PASSWORD )); then
  printf 'Temporary password (displayed once): %s\n' "$PASSWORD"
fi
