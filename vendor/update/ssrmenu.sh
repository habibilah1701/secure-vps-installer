#!/usr/bin/env bash
set -Eeuo pipefail
clear
printf '\033[1;36m%s\033[0m\n' 'SHADOWSOCKS-R MENU'
printf '%s\n' '1. Create Account SSR' '2. Delete Account SSR' '3. Extend Account SSR' '4. Other SSR Menu' '5. Main Menu' '6. Exit'
read -r -p 'Select [1-6]: ' choice
case "$choice" in
  1) command -v addssr >/dev/null && addssr || echo 'addssr unavailable' ;;
  2) command -v delssr >/dev/null && delssr || echo 'delssr unavailable' ;;
  3) command -v renewssr >/dev/null && renewssr || echo 'renewssr unavailable' ;;
  4) command -v ssr >/dev/null && ssr || echo 'ssr unavailable' ;;
  5) command -v menu >/dev/null && menu || true ;;
  6) exit 0 ;;
  *) echo 'Invalid option' ;;
esac
