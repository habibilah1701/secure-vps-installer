#!/bin/bash
# ==========================================
# Color
# hapus menu
rm -rf menu
rm -rf ipsaya
rm -rf sl-fix
rm -rf sshovpnmenu
rm -rf l2tpmenu
rm -rf pptpmenu
rm -rf sstpmenu
rm -rf wgmenu
rm -rf ssmenu
rm -rf ssrmenu
rm -rf vmessmenu
rm -rf vlessmenu
rm -rf grpcmenu
rm -rf grpcupdate
rm -rf trmenu
rm -rf trgomenu
rm -rf setmenu
rm -rf slowdnsmenu
rm -rf running
rm -rf copyrepo

# download menu
cd /usr/bin
rm -rf menu
rm -rf menuinfo
rm -rf restart
rm -rf slhost
rm -rf install-sldns
rm -rf addssh
wget -O install-sldns "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/SLDNS/install-sldns"
wget -O restart "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/ssh/restart.sh"
wget -O addssh "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/ssh/addssh.sh"
wget -O menu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/menu.sh"
wget -O ipsaya "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/ipsaya.sh"
wget -O sl-fix "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/sslh-fix/sl-fix"
wget -O sshovpnmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/sshovpn.sh"
wget -O l2tpmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/l2tpmenu.sh"
wget -O pptpmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/pptpmenu.sh"
wget -O sstpmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/sstpmenu.sh"
wget -O wgmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/wgmenu.sh"
wget -O ssmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/ssmenu.sh"
wget -O ssrmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/ssrmenu.sh"
wget -O vmessmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/vmessmenu.sh"
wget -O vlessmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/vlessmenu.sh"
wget -O xray-grpc "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/grpc/xray-grpc.sh"
wget -O grpcmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/grpcmenu.sh"
wget -O grpcupdate "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/grpcupdate.sh"
wget -O trmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/trmenu.sh"
wget -O trgomenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/trgomenu.sh"
wget -O setmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/setmenu.sh"
wget -O slowdnsmenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/slowdnsmenu.sh"
wget -O running "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/running.sh"
wget -O updatemenu "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/updatemenu.sh"
wget -O copyrepo "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/salin/copyrepo.sh"
wget -O slhost "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/ssh/slhost.sh"
wget -O sl-download-info "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/contohinfo/sl-download-info.sh"
wget -O menuinfo "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/update/menuinfo.sh"
wget -O install-ss-plugin "https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/vendor/shadowsocks-plugin/install-ss-plugin.sh"

chmod +x install-ss-plugin
chmod +x xray-grpc
chmod +x install-sldns
chmod +x restart
chmod +x addssh
chmod +x grpcmenu2
chmod +x grpc2
chmod +x grpcupdate2
chmod +x sl-download-info
chmod +x menuinfo
chmod +x slhost
chmod +x copyrepo
chmod +x menu
chmod +x ipsaya
chmod +x sl-fix
chmod +x sshovpnmenu
chmod +x l2tpmenu
chmod +x pptpmenu
chmod +x sstpmenu
chmod +x wgmenu
chmod +x ssmenu
chmod +x ssrmenu
chmod +x vmessmenu
chmod +x vlessmenu
chmod +x grpcmenu
chmod +x grpcupdate
chmod +x trmenu
chmod +x trgomenu
chmod +x setmenu
chmod +x slowdnsmenu
chmod +x running
chmod +x updatemenu
sl-download-info
install-sldns
install-ss-plugin
xray-grpc
cd
