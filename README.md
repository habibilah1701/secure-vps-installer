# HABIBILLAH VPS Installer

Installer publik untuk memasang **feature set lengkap script VPS asli** pada banyak VPS Ubuntu/Debian. Setelah instalasi, server memiliki menu interaktif tengah dengan branding **HABIBILLAH**, pembuat **Habibillah**, dan WhatsApp **081374452477**.

## Instalasi satu perintah

Pada VPS baru Ubuntu 24.04 LTS atau Debian stable:

```bash
curl -fsSL https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/setup.sh | sudo bash -s -- --profile full
```

Installer menjalankan update dan upgrade sistem, memasang dependensi, menginstal modul layanan dari source vendor yang dibundel, membuat material kriptografi unik untuk VPS tersebut, lalu membuka menu. Gunakan `--no-menu` untuk pengujian non-interaktif.

## Fitur menu

Menu mencakup pembuatan, penghapusan, perpanjangan, dan pemeriksaan akun untuk SSH/OpenVPN, L2TP, PPTP, SSTP, WireGuard, Shadowsocks, SSR, VMess, VLESS, Trojan, Trojan-Go, serta operasi domain, port, backup/restore, Webmin, bandwidth, RAM, reboot, speedtest, informasi sistem, dan informasi script.

Fitur legacy dipertahankan agar kompatibel dengan kebutuhan script asli, tetapi setiap kegagalan modul dicatat di `/var/log/habibillah-installer.log`; installer tidak boleh mengklaim semua layanan sukses jika ada modul yang gagal.

## Port SSH dan domain

Port SSH default: `22,3369,2269,169,99`. Domain tidak wajib untuk SSH atau VPN dasar. Menu domain dapat dipakai kemudian jika Anda sudah memiliki DNS yang mengarah ke VPS. Sertifikat yang dibuat otomatis tanpa domain adalah self-signed dan bukan pengganti sertifikat Let’s Encrypt.

## Multi-server

Installer tidak menyimpan IP VPS, domain, token, password, konfigurasi rclone, sertifikat, atau private key dari server tertentu. Setiap VPS membuat:

- DH parameters unik di `/etc/ssl/private/habibillah-dhparam.pem`.
- Kunci dan sertifikat lokal di `/etc/ssl/private/habibillah.key` dan `/etc/ssl/certs/habibillah.crt`.
- Log lokal di `/var/log/habibillah-installer.log`.
- Konfigurasi layanan berdasarkan hostname dan IP server saat instalasi.

Dengan demikian URL installer yang sama dapat digunakan pada banyak VPS. Jangan menaruh token provider, password backup, atau private key di repository public.

## Backup

File `rclone.conf` bawaan dan password email script lama sengaja tidak dibundel. Setelah instalasi, konfigurasikan storage milik masing-masing server:

```bash
sudo rclone config
sudo backup-status
```

Hal ini mencegah satu token backup dipakai oleh semua VPS.

## Pemeriksaan sebelum produksi

```bash
curl -fsSL https://raw.githubusercontent.com/habibilah1701/secure-vps-installer/main/setup.sh | sudo bash -s -- --profile full --no-menu
sudo ss -tulpn
sudo systemctl --failed
sudo systemctl status ssh fail2ban nginx --no-pager
sudo menu
```

Gunakan snapshot atau console provider. Beberapa layanan legacy seperti PPTP, SSR, OHP, dan SlowDNS memiliki risiko keamanan atau kompatibilitas; layanan tersebut dipertahankan untuk kesesuaian fitur, tetapi sebaiknya dibatasi firewall dan tidak digunakan untuk data sensitif.
