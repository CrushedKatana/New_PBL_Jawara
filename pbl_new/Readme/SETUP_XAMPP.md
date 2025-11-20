# Setup XAMPP untuk Marketplace RT/RW

Panduan lengkap untuk mengatur database MySQL dan REST API PHP menggunakan XAMPP.

## Prasyarat

1. **XAMPP** sudah terinstal di komputer
   - Download dari: https://www.apachefriends.org/
   - Versi yang direkomendasikan: XAMPP 8.0 atau lebih baru

2. **Flutter SDK** sudah terinstal
   - Untuk menjalankan aplikasi mobile

## Langkah 1: Setup Database MySQL

### 1.1 Jalankan XAMPP
1. Buka **XAMPP Control Panel**
2. Start **Apache** dan **MySQL**
3. Pastikan kedua service berjalan dengan baik (indikator hijau)

### 1.2 Buat Database
1. Buka browser, akses: `http://localhost/phpmyadmin`
2. Klik tab **SQL**
3. Copy seluruh isi file `backend/database.sql` dari project
4. Paste ke kolom SQL dan klik **Go**
5. Database `marketplace_rtrw` akan dibuat beserta tabel-tabelnya

### 1.3 Verifikasi Database
Pastikan database memiliki tabel-tabel berikut:
- `users` - Data pengguna
- `products` - Data produk
- `messages` - Data pesan/chat
- `categories` - Kategori produk

## Langkah 2: Setup REST API PHP

### 2.1 Copy File API ke htdocs
1. Buka folder instalasi XAMPP (biasanya `C:\xampp`)
2. Masuk ke folder `htdocs`
3. Buat folder baru: `marketplace_api`
4. Copy semua file dari folder `backend` project ke `C:\xampp\htdocs\marketplace_api\`

Struktur folder harus seperti ini:
```
C:\xampp\htdocs\marketplace_api\
├── config.php
├── auth.php
├── products.php
├── chat.php
├── categories.php
└── database.sql
```

### 2.2 Konfigurasi Database
1. Buka file `config.php` di folder `marketplace_api`
2. Pastikan konfigurasi database sudah benar:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Kosong untuk default XAMPP
define('DB_NAME', 'marketplace_rtrw');
```

### 2.3 Test API
Buka browser dan test endpoint berikut:

**Test Products API:**
- URL: `http://localhost/marketplace_api/products.php`
- Seharusnya menampilkan JSON data produk

**Test Categories API:**
- URL: `http://localhost/marketplace_api/categories.php`
- Seharusnya menampilkan JSON data kategori

## Langkah 3: Setup Flutter App

### 3.1 Install Dependencies
Buka terminal di folder project Flutter, jalankan:
```bash
flutter pub get
```

### 3.2 Konfigurasi API URL

#### Untuk Emulator Android:
Edit file `lib/config/api_config.dart`, ubah baseUrl menjadi:
```dart
static const String baseUrl = 'http://10.0.2.2/marketplace_api';
```

#### Untuk Emulator iOS:
```dart
static const String baseUrl = 'http://localhost/marketplace_api';
```

#### Untuk Device Fisik:
1. Cari IP address komputer Anda:
   - Windows: Buka CMD, ketik `ipconfig`
   - Cari **IPv4 Address** (misal: 192.168.1.100)
2. Ubah baseUrl:
```dart
static const String baseUrl = 'http://192.168.1.100/marketplace_api';
```
3. Pastikan device dan komputer terhubung ke WiFi yang sama

### 3.3 Jalankan Aplikasi
```bash
flutter run
```

## Langkah 4: Testing

### 4.1 Test Register
1. Buka aplikasi Flutter
2. Pilih "Register"
3. Isi data:
   - Nama: Test User
   - Email: test@email.com
   - Password: 123456
   - Phone: 081234567890
   - RT/RW: 001/005
4. Klik Register
5. Cek di phpMyAdmin apakah data tersimpan di tabel `users`

### 4.2 Test Login
1. Gunakan email dan password yang sudah terdaftar
2. Login seharusnya berhasil

### 4.3 Test Add Product
1. Login terlebih dahulu
2. Tambah produk baru dengan data lengkap
3. Cek di phpMyAdmin apakah data tersimpan di tabel `products`

## Troubleshooting

### Error: Connection Refused
**Penyebab:** Apache atau MySQL belum jalan
**Solusi:** 
1. Buka XAMPP Control Panel
2. Start Apache dan MySQL
3. Pastikan tidak ada aplikasi lain yang menggunakan port 80 dan 3306

### Error: Database Connection Failed
**Penyebab:** Konfigurasi database salah atau database belum dibuat
**Solusi:**
1. Cek file `config.php`, pastikan kredensial benar
2. Pastikan database `marketplace_rtrw` sudah dibuat di phpMyAdmin

### Error: 404 Not Found
**Penyebab:** File API tidak ditemukan
**Solusi:**
1. Pastikan file PHP sudah di-copy ke `C:\xampp\htdocs\marketplace_api\`
2. Cek URL, pastikan sesuai dengan nama folder

### Error: Connection Timeout di Device Fisik
**Penyebab:** Device dan komputer tidak terhubung ke WiFi yang sama, atau firewall memblokir
**Solusi:**
1. Pastikan device dan komputer di WiFi yang sama
2. Matikan firewall Windows sementara atau izinkan Apache
3. Ping IP komputer dari device untuk memastikan koneksi

### Error: CORS Policy
**Penyebab:** Browser memblokir request cross-origin
**Solusi:** File `config.php` sudah include CORS headers. Pastikan header sudah ada:
```php
header('Access-Control-Allow-Origin: *');
```

## Data Sample

Database sudah terisi dengan data sample:

**Users:**
- Email: `budi@email.com` | Password: `password`
- Email: `siti@email.com` | Password: `password`
- Email: `ahmad@email.com` | Password: `password`

**Products:**
- Nasi Goreng Spesial - Rp 15.000
- Laptop Bekas - Rp 3.500.000

## Keamanan

⚠️ **PENTING:** Setup ini untuk development/testing saja!

Untuk production, pastikan:
1. Gunakan password MySQL yang kuat
2. Gunakan prepared statements untuk semua query (sudah ada di PHP)
3. Implementasi JWT untuk authentication
4. Gunakan HTTPS
5. Validasi input di server side
6. Batasi CORS hanya untuk domain tertentu

## Backup Database

Untuk backup database:
1. Buka phpMyAdmin
2. Pilih database `marketplace_rtrw`
3. Klik tab **Export**
4. Pilih **Quick** atau **Custom**
5. Klik **Go** untuk download file .sql

## Update API

Jika Anda mengubah file PHP di folder `backend` project:
1. Copy file yang diubah
2. Paste ke `C:\xampp\htdocs\marketplace_api\`
3. Replace file lama
4. Tidak perlu restart Apache

## Port yang Digunakan

- **Apache (HTTP):** Port 80
- **MySQL:** Port 3306
- **phpMyAdmin:** `http://localhost/phpmyadmin`
- **API Base:** `http://localhost/marketplace_api`

## Referensi File

| File | Fungsi |
|------|--------|
| `config.php` | Koneksi database dan helper functions |
| `auth.php` | Login, register, user profile |
| `products.php` | CRUD produk |
| `chat.php` | Pesan/chat |
| `categories.php` | Daftar kategori |
| `database.sql` | Schema dan data sample |

---

**Selamat! Setup XAMPP untuk Marketplace RT/RW sudah selesai.**

Jika ada masalah, cek file log:
- Apache Error Log: `C:\xampp\apache\logs\error.log`
- PHP Error: Aktifkan `display_errors` di `php.ini`
