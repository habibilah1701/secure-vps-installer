#!/usr/bin/env bash
# One-command bootstrap or local entrypoint.
set -Eeuo pipefail

REPO_RAW="https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/install.sh"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)"

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/install.sh" ]]; then
  exec bash "$SCRIPT_DIR/install.sh" "$@"
fi

TMP_INSTALLER="$(mktemp /tmp/secure-vps-install.XXXXXX.sh)"
cleanup() { rm -f "$TMP_INSTALLER"; }
trap cleanup EXIT

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  if [[ "${EUID:-$(id -u)}" -eq 0 ]] && command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y ca-certificates curl
  else
    echo 'curl atau wget diperlukan; bootstrap tidak dapat memasangnya otomatis' >&2
    exit 1
  fi
fi

if command -v curl >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -fsSL "$REPO_RAW" -o "$TMP_INSTALLER"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TMP_INSTALLER" "$REPO_RAW"
else
  echo 'curl atau wget diperlukan untuk mengambil installer' >&2
  exit 1
fi

chmod 700 "$TMP_INSTALLER"
exec bash "$TMP_INSTALLER" "$@"
