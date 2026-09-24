# Security notes

## Perbaikan error 404

Installer asli menimpa `/etc/ssh/sshd_config` dengan `vpsroot.sh` dan `addhost.sh` dari URL remote. Jika file tidak tersedia atau berubah, konfigurasi SSH dapat rusak. Versi HABIBILLAH menggunakan `vendor/vpsroot.sh` lokal yang menulis drop-in, menjalankan `sshd -t`, dan tidak mengambil `addhost.sh`.

## Portabilitas multi-VPS

Tidak ada IP, domain, sertifikat, private key, rclone config, token, atau password server tertentu di repository. Material DH dan sertifikat self-signed dibuat pada saat instalasi di setiap VPS. Backup remote harus dikonfigurasi sendiri dengan `rclone config`.

## Kompatibilitas versus keamanan

Profile `full` mempertahankan modul legacy dari script asli—termasuk PPTP, SSR, OHP, dan SlowDNS—karena itu diminta untuk kompatibilitas fitur. Modul tersebut memiliki risiko keamanan/kriptografi dan harus dibatasi pada firewall provider. Installer mencatat kegagalan modul dan tidak menyamarkan kegagalan sebagai sukses.

Root tetap tidak diberi password oleh installer. Jangan memasukkan password, token, atau private key ke repository public.
