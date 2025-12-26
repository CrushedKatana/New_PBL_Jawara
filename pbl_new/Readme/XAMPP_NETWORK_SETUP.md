# Setup XAMPP untuk Network Access

## 1. Import Database

1. Buka **XAMPP Control Panel** dan start **Apache** dan **MySQL**
2. Buka browser dan akses **http://localhost/phpmyadmin**
3. Buat database baru dengan nama `marketplace_rtrw`
4. Klik tab **Import**
5. Pilih file `database.sql` dari folder `backend`
6. Klik **Go** untuk mengimport

## 2. Konfigurasi Apache untuk Network Access

### A. Edit httpd.conf
1. Buka **XAMPP Control Panel**
2. Klik **Config** pada Apache, pilih **httpd.conf**
3. Cari baris yang berisi `Listen 80` (sekitar baris 60)
4. Pastikan tidak ada `Listen 127.0.0.1:80` (jika ada, ganti dengan `Listen 80`)
5. Cari baris `ServerName` (sekitar baris 227)
6. Ubah/tambahkan menjadi:
   ```
   ServerName 192.168.1.7:80
   ```
7. Save dan close

### B. Edit httpd-vhosts.conf (Opsional tapi disarankan)
1. Klik **Config** pada Apache, pilih **httpd-vhosts.conf**
2. Tambahkan di akhir file:
   ```apache
   <VirtualHost *:80>
       DocumentRoot "C:/xampp/htdocs"
       ServerName localhost
       ServerAlias 192.168.1.7
       <Directory "C:/xampp/htdocs">
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```
3. Save dan close

### C. Restart Apache
1. Di XAMPP Control Panel, klik **Stop** pada Apache
2. Tunggu beberapa detik, lalu klik **Start** lagi

## 3. Konfigurasi Windows Firewall

### A. Buat Inbound Rule untuk Apache
1. Buka **Windows Defender Firewall**
2. Klik **Advanced settings**
3. Klik **Inbound Rules** di sidebar kiri
4. Klik **New Rule...** di sidebar kanan
5. Pilih **Port**, klik **Next**
6. Pilih **TCP**, masukkan port **80**, klik **Next**
7. Pilih **Allow the connection**, klik **Next**
8. Centang semua (Domain, Private, Public), klik **Next**
9. Beri nama: **XAMPP Apache Server**, klik **Finish**

### B. Buat Inbound Rule untuk MySQL (Opsional)
Ulangi langkah di atas, tapi gunakan port **3306** dan nama **XAMPP MySQL Server**

## 4. Test Koneksi dari Komputer Lain

### A. Dari PC yang sama (localhost)
Buka browser dan akses:
- **Backend API**: http://localhost/jawara/backend/products.php
- **phpMyAdmin**: http://localhost/phpmyadmin

### B. Dari perangkat lain di network yang sama
Buka browser dan akses:
- **Backend API**: http://192.168.1.7/jawara/backend/products.php
- **phpMyAdmin**: http://192.168.1.7/phpmyadmin

Jika muncul JSON response dari products.php, berarti sukses!

## 5. Test dengan Flutter App

### A. Test di Web
```cmd
cd d:\CloneGithub\New_PBL_Jawara\pbl_new
flutter run -d chrome
```
- Login dengan credentials:
  - Admin: admin@jawara.com / password123
  - RT: budi.rt05@jawara.com / password123
  - Warga: aminah@jawara.com / password123

### B. Test di Android Emulator
```cmd
flutter run -d emulator-5554
```

### C. Test di Physical Device
1. Hubungkan HP ke PC via USB
2. Enable **USB Debugging** di HP
3. Pastikan HP dan PC di **network WiFi yang sama**
4. Run:
   ```cmd
   flutter devices
   flutter run -d <device-id>
   ```

## 6. Troubleshooting

### Problem: "Connection refused" atau timeout
**Solusi:**
1. Pastikan XAMPP Apache berjalan (lampu hijau di Control Panel)
2. Cek firewall rules sudah dibuat dengan benar
3. Ping IP dari perangkat lain: `ping 192.168.1.7`
4. Test dengan curl: `curl http://192.168.1.7/jawara/backend/products.php`

### Problem: "Access forbidden" atau 403 error
**Solusi:**
1. Pastikan folder `jawara/backend` ada di `C:\xampp\htdocs\`
2. Cek file permissions (bukan read-only)
3. Edit httpd.conf, cari `<Directory "C:/xampp/htdocs">` dan pastikan ada:
   ```
   Require all granted
   ```

### Problem: Database connection error
**Solusi:**
1. Buka `backend/config.php`
2. Pastikan credentials benar:
   ```php
   $host = 'localhost';
   $username = 'root';
   $password = ''; // kosongkan jika default XAMPP
   $database = 'marketplace_rtrw';
   ```
3. Test koneksi MySQL di phpMyAdmin

### Problem: Flutter app tidak bisa connect dari mobile
**Solusi:**
1. Pastikan HP dan PC di WiFi yang sama
2. Cek IP PC dengan `ipconfig` (pastikan 192.168.1.7)
3. Test akses http://192.168.1.7/jawara/backend/products.php dari browser HP
4. Hot restart Flutter app (tekan 'r' di terminal atau Shift+R)

## 7. IP Address Changes

Jika IP komputer berubah (misalnya pindah WiFi):
1. Cek IP baru dengan: `ipconfig | findstr IPv4`
2. Update `lib/config/api_config.dart`:
   ```dart
   const networkIp = '192.168.X.X'; // IP baru
   ```
3. Update `backend/httpd.conf` ServerName (jika perlu)
4. Restart Apache
5. Hot restart Flutter app

## 8. Demo Credentials

Semua user menggunakan password: **password123**

### Admin
- Email: admin@jawara.com
- Role: admin
- Access: Full system access

### RT Officers
- Email: budi.rt05@jawara.com (RT 05)
- Email: susi.rt01@jawara.com (RT 01)
- Email: agus.rt02@jawara.com (RT 02)
- Email: lina.rt03@jawara.com (RT 03)
- Email: yanto.rt04@jawara.com (RT 04)
- Role: rt
- Access: Approve produk, lihat metrics RT

### Warga
- Email: aminah@jawara.com (RT 05)
- Email: andi@jawara.com (RT 01)
- Email: dewi@jawara.com (RT 01)
- Email: fajar@jawara.com (RT 02)
- Email: gita@jawara.com (RT 02)
- Dan lain-lain (lihat database.sql)
- Role: warga
- Access: Jual/beli produk, chat, PCVK detection

## 9. Backend Endpoints Available

- **Auth**: /jawara/backend/auth.php
- **Products**: /jawara/backend/products.php
- **Categories**: /jawara/backend/categories.php
- **Chat**: /jawara/backend/chat.php
- **Users**: /jawara/backend/users.php
- **RT Metrics**: /jawara/backend/rt_metrics.php
- **Activities**: /jawara/backend/activities.php
- **Transactions**: /jawara/backend/transactions.php
- **ML Detection**: /jawara/backend/ml_detection.php
- **ML History**: /jawara/backend/ml_detection_history.php

Test dengan:
```bash
curl http://192.168.1.7/jawara/backend/products.php
curl http://192.168.1.7/jawara/backend/categories.php
```

## 10. Next Steps

Setelah setup berhasil:
1. ✅ Test login dari web browser (http://localhost:PORT)
2. ✅ Test login dari Android emulator
3. ✅ Test dari physical device (HP)
4. ⏳ Integrate Firebase Cloud Messaging (FCM)
5. ⏳ Update Admin screens untuk fetch dari database
6. ⏳ Deploy production (gunakan hosting server jika perlu)
