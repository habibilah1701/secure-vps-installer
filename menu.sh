#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'; RED='\033[1;31m'; RESET='\033[0m'

center() {
  local line="$1" width pad
  width=$(tput cols 2>/dev/null || echo 80)
  pad=$(( (width - ${#line}) / 2 )); (( pad < 0 )) && pad=0
  printf '%*s%b\n' "$pad" '' "$line"
}

logo() {
  clear
  center "${CYAN}██╗  ██╗ █████╗ ██████╗ ██╗██████╗ ██╗██╗     ██╗      █████╗ ██╗  ██╗${RESET}"
  center "${CYAN}██║  ██║██╔══██╗██╔══██╗██║██╔══██╗██║██║     ██║     ██╔══██╗██║  ██║${RESET}"
  center "${CYAN}███████║███████║██████╔╝██║██████╔╝██║██║     ██║     ███████║███████║${RESET}"
  center "${CYAN}██╔══██║██╔══██║██╔══██╗██║██╔══██╗██║██║     ██║     ██╔══██║██╔══██║${RESET}"
  center "${CYAN}██║  ██║██║  ██║██████╔╝██║██║  ██║██║███████╗███████╗██║  ██║██║  ██║${RESET}"
  center "${GREEN}Pembuat: Habibillah  |  WhatsApp: 081374452477${RESET}"
  center "${WHITE}VPS MANAGEMENT MENU${RESET}"
  printf '\n'
}

items=(
'Create SSH & OpenVPN Account' 'Trial SSH & OpenVPN Account' 'Extend SSH Account' 'Check SSH Login' 'SSH Member List' 'Delete SSH Account' 'Delete Expired SSH' 'Set SSH Autokill' 'Multi-login SSH' 'Restart All Services'
'Create L2TP Account' 'Delete L2TP Account' 'Extend L2TP Account' 'Create PPTP Account' 'Delete PPTP Account' 'Extend PPTP Account'
'Create SSTP Account' 'Delete SSTP Account' 'Extend SSTP Account' 'Check SSTP Login' 'Create WireGuard Account' 'Delete WireGuard Account' 'Extend WireGuard Account'
'Create Shadowsocks Account' 'Delete Shadowsocks Account' 'Extend Shadowsocks Account' 'Check Shadowsocks Login' 'Create SSR Account' 'Delete SSR Account' 'Extend SSR Account' 'SSR Menu'
'Create VMess WebSocket' 'Delete VMess WebSocket' 'Extend VMess Account' 'Check VMess Login' 'Renew Xray Certificate' 'Create VLESS WebSocket' 'Delete VLESS WebSocket' 'Extend VLESS Account' 'Check VLESS Login'
'Create Trojan Account' 'Delete Trojan Account' 'Extend Trojan Account' 'Check Trojan Login' 'Create Trojan Go' 'Delete Trojan Go' 'Extend Trojan Go' 'Check Trojan Go'
'Add or Change VPS Domain' 'Change Service Port' 'Auto Backup' 'Backup VPS' 'Restore VPS' 'Webmin Menu' 'Limit Bandwidth' 'RAM Usage' 'Reboot VPS' 'Speedtest VPS' 'System Information' 'About HABIBILLAH'
)
cmds=(
addssh trialssh renewssh cekssh member delssh delexp autokill ceklim restart addl2tp dell2tp renewl2tp addpptp delpptp renewpptp addsstp delsstp renewsstp ceksstp addwg delwg renewwg addss delss renewss cekss addssr delssr renewssr ssr addvmess delvmess renewvmess cekvmess certv2ray addvless delvless renewvless cekvless addtrojan deltrojan renewtrojan cektrojan addtrgo deltrgo renewtrgo cektrgo addhost changeport autobackup backup restore wbmn limitspeed ram reboot speedtest info about
)

while true; do
  logo
  for i in "${!items[@]}"; do printf '  %b%02d%b) %s\n' "$YELLOW" "$((i+1))" "$RESET" "${items[$i]}"; done
  printf '\n  %b 0) Exit%b\n\n' "$RED" "$RESET"
  read -r -p '  Select option [0-60]: ' choice || exit 0
  [[ "$choice" =~ ^[0-9]+$ ]] || continue
  (( choice == 0 )) && exit 0
  (( choice >= 1 && choice <= ${#cmds[@]} )) || continue
  cmd="${cmds[$((choice-1))]}"
  clear
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" || true
  else
    printf '%b\n' "${RED}Module '$cmd' is not installed or failed its installation.${RESET}"
    printf '%b\n' "${YELLOW}Installer tidak akan melaporkan modul ini sukses jika command tidak tersedia.${RESET}"
  fi
  printf '\n'; read -r -p 'Press Enter to return to menu...' _ || exit 0
done
