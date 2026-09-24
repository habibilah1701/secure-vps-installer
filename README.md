# Secure VPS Installer

Installer modular untuk Ubuntu dan Debian yang memprioritaskan **auditabilitas, paket resmi, dan perubahan yang dapat dipulihkan**. Proyek ini adalah pengganti aman untuk installer lama yang mengunduh dan mengeksekusi banyak skrip sebagai `root`.

> **Perbaikan error 404:** versi ini tidak bergantung pada `vpsroot.sh` atau `addhost.sh` dari URL raw GitHub. File-file tersebut adalah sumber kegagalan pada installer lama ketika salah satunya tidak tersedia, lalu konfigurasi SSH telah berubah sebagian. Lihat [catatan keamanan](SECURITY.md).

## Dukungan

Target utama adalah Ubuntu LTS dan Debian stable yang masih didukung oleh penyedia VPS. Script memvalidasi OS sebelum melakukan perubahan.

## Penggunaan

```bash
chmod 700 install.sh
sudo ./install.sh --dry-run --profile baseline
sudo ./install.sh --profile baseline
sudo ./install.sh --profile vpn
sudo ./install.sh --profile full
sudo ./install.sh --profile full --ssh-ports 22,3369,2269,169,99
```

Profile `baseline` memasang OpenSSH, Fail2Ban, nftables, WireGuard tools, dan Nginx. Profile `vpn` menambahkan OpenVPN, strongSwan, xl2tpd, serta Shadowsocks-libev jika tersedia melalui package manager. Profile `full` menambahkan Certbot.

Jalankan `--dry-run` lebih dahulu. Gunakan snapshot atau console provider sebelum mengubah SSH dan firewall. Port SSH default hanya `22`; port tambahan seperti `3369`, `2269`, `169`, dan `99` harus diminta secara eksplisit. Script tidak membuat akun VPN, tidak membuat password bawaan, dan tidak menyimpan token.

Untuk mencegah terkunci dari VPS, konfigurasi SSH baru ditulis ke drop-in, konfigurasi diuji dengan `sshd -t`, dan file konfigurasi lama dicadangkan. `PermitRootLogin` dibatasi ke autentikasi key dan `PasswordAuthentication` tetap nonaktif. Jangan mengubahnya menjadi `PermitRootLogin yes` atau `PasswordAuthentication yes` tanpa threat model dan aturan firewall yang jelas.

## Akun SSH berjangka (opsional)

Jika akun username/password tetap dibutuhkan, gunakan modul terpisah:

```bash
chmod 700 ssh-user.sh
sudo ./ssh-user.sh --username pelanggan1 --days 30 --enable-password-auth
```

Script menolak akun `root`, membatasi masa berlaku maksimal 730 hari, membuat password acak sementara bila password tidak diberikan melalui stdin, dan tidak menanam password di source code. Untuk memasukkan password tanpa menampilkannya di command history, gunakan:

```bash
read -r -s PASSWORD
printf '%s\n' "$PASSWORD" | sudo ./ssh-user.sh --username pelanggan1 --days 30 --password-stdin --enable-password-auth
unset PASSWORD
```

`--enable-password-auth` harus ditulis secara eksplisit karena password SSH meningkatkan risiko brute-force. Fail2Ban dan firewall provider tetap wajib digunakan. Root tetap `prohibit-password` dan modul tidak membuat akun root tambahan.

## Komponen yang sengaja tidak dipasang

PPTP, SSR, OHP, SlowDNS, installer `curl|bash`, dan file konfigurasi dari URL pihak ketiga dikeluarkan karena usang, memiliki risiko kriptografi atau supply-chain, atau tidak bisa diverifikasi dengan aman. Xray juga tidak diambil dari skrip installer remote; gunakan paket atau release yang telah diverifikasi dan dipin secara terpisah jika benar-benar diperlukan.

`--allow-legacy` hanya merupakan acknowledgement untuk kompatibilitas CLI; flag tersebut **tidak** mengaktifkan layanan legacy. Komponen legacy harus ditinjau dan diimplementasikan sebagai modul terpisah dengan versi dan checksum yang jelas.

## Prinsip keamanan

- Semua instalasi menggunakan `apt-get`; tidak ada eksekusi shell dari isi URL.
- Konfigurasi SSH baru ditulis ke file drop-in dan divalidasi menggunakan `sshd -t`.
- File log dibuat dengan mode `0600`.
- Password, private key, token, dan endpoint backup tidak ditanam di source code.
- Layanan otomatis dibatasi pada service yang dipilih oleh profile.
- Tidak ada auto-reboot, penghapusan file, perubahan PAM, atau penggantian konfigurasi firewall secara massal.

## Audit lokal

```bash
bash -n install.sh
shellcheck install.sh
sudo ./install.sh --dry-run --profile full
```

Tinjau perubahan dengan `git diff`, dan jangan menjalankan script dari branch atau commit yang belum diperiksa.

## Catatan

Script ini tidak menjanjikan bahwa semua layanan pada installer lama tersedia. Menjaga semua fitur lama sekaligus tidak kompatibel dengan tujuan keamanan; layanan tambahan harus ditambahkan satu per satu, dengan threat model, paket/release yang dipin, checksum, konfigurasi minimal, dan pengujian rollback.
