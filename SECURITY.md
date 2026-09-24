# Security notes

## Perbaikan error 404 pada installer lama

Installer lama mengambil file remote seperti `vpsroot.sh`, `sshd_config`, dan `addhost.sh` dari repository lain lalu menimpakan hasilnya ke `/etc/ssh/sshd_config` dan menjalankan `systemctl restart sshd`. Jika `addhost.sh` tidak ada atau URL menghasilkan `404`, proses dapat berhenti setelah sebagian konfigurasi diterapkan; akibatnya SSH dapat gagal restart atau akses VPS bisa hilang.

Versi ini **tidak menggunakan** `vpsroot.sh`, `addhost.sh`, `wget` ke konfigurasi SSH, atau `curl|bash`. Konfigurasi SSH dikelola secara lokal melalui drop-in `/etc/ssh/sshd_config.d/99-secure-vps-installer.conf`, dicadangkan, dan divalidasi dengan `sshd -t` sebelum service dijalankan.

## Port dan autentikasi

Port default installer adalah `22,3369,2269,169,99`. Daftar tersebut dapat diganti dengan `--ssh-ports`, dan provider firewall juga harus disesuaikan. Script tidak mengaktifkan `PermitRootLogin yes` dan tidak mengaktifkan `PasswordAuthentication yes`; akses key-based lebih aman dan mencegah kredensial bawaan.

Jika validasi SSH gagal, installer menghapus drop-in baru dan mengembalikan konfigurasi utama dari backup yang dibuat pada proses tersebut. Tetap gunakan console provider atau snapshot sebagai jalur pemulihan.
