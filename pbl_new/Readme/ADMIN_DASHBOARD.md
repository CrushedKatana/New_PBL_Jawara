# Admin Dashboard - Jawara Marketplace

## Deskripsi

Dashboard admin untuk mengelola Marketplace Jawara, aplikasi marketplace pakaian berbasis komunitas RT/RW Indonesia dengan fitur AI Computer Vision.

## Fitur Admin Dashboard

### 1. **Dashboard Utama** (`AdminDashboardScreen`)

Dashboard utama menampilkan statistik global dan performa sistem:

#### Statistik Global
- **Total Warga**: 702 pengguna terdaftar (+12 pertumbuhan)
- **Total Produk**: 349 produk aktif (+23 pertumbuhan)
- **Transaksi**: 1,400 transaksi (+15% pertumbuhan)
- **GMV Bulan Ini**: 52.4M (+8% pertumbuhan)

#### Manajemen
- **Kelola User**: Akses ke manajemen pengguna (702 akun)
- **RT/RW**: Monitoring 5 RT aktif
- **ML Analytics**: Akses ke analitik model PCVK
- **Laporan**: Pengelolaan laporan (2 pending dengan notifikasi)

#### Performa RT
Tabel performa untuk setiap RT menampilkan:
- Jumlah warga
- Jumlah produk
- Total transaksi

Data per RT:
- RT 01: 156 warga, 89 produk, 342 transaksi
- RT 02: 134 warga, 67 produk, 278 transaksi
- RT 03: 142 warga, 72 produk, 301 transaksi
- RT 04: 128 warga, 54 produk, 245 transaksi
- RT 05: 142 warga, 67 produk, 234 transaksi

#### Status Sistem
- PCVK Model: Active ✅
- Database: Healthy ✅
- API Server: Running ✅

---

### 2. **User Management** (`UserManagementScreen`)

Sistem manajemen pengguna lengkap:

#### Fitur Pencarian
- Search bar untuk mencari user
- Filter users berdasarkan kriteria

#### Statistik User
- Total: 702 pengguna
- Warga: 685 pengguna
- RT/RW: 15 officer
- Admin: 2 administrator

#### Daftar User
Setiap kartu user menampilkan:
- Avatar dengan initial atau icon sesuai role
- Nama lengkap
- Role (Warga, RT Officer, atau Admin)
- Badge khusus untuk RT Officer dan Admin
- RT assignment (jika ada)
- Status (Active/Suspended)
- Tanggal bergabung
- Menu aksi

#### Role Types
1. **Warga** - Pengguna biasa
2. **RT Officer** - Petugas RT dengan badge khusus
3. **Admin** - Administrator dengan badge purple

---

### 3. **ML Analytics** (`MLAnalyticsScreen`)

Dashboard analitik untuk model Machine Learning PCVK (Product Category Vision Classifier):

#### Model Performance
- **Akurasi Global**: 92.4% ✅
- **Total Deteksi**: 758 deteksi
- **Avg Response**: 0.3s ⚡
- **Improvement**: +8.2% 📈

#### Akurasi per Kategori
Grafik progress bar untuk setiap kategori produk:
- T-Shirt: ~95%
- Kemeja: ~95%
- Topi: ~95%
- Sepatu: ~95%
- Jaket: ~95%

#### Distribusi Deteksi
Pie chart breakdown:
- T-Shirt: 32%
- Kemeja: 23%
- Sepatu: 18%
- Topi: 12%

#### Confusion Matrix
Preview confusion matrix untuk evaluasi model

#### Deteksi Terbaru
List real-time deteksi terbaru dengan:
- Nama produk yang terdeteksi
- Timestamp
- Confidence level

Contoh:
- T-Shirt (2 menit lalu) - 96.5% confidence
- Kemeja (5 menit lalu) - 94.2% confidence
- Sepatu (10 menit lalu) - 98.1% confidence
- Jaket (15 menit lalu) - 92.7% confidence

---

### 4. **Admin Profile** (`AdminProfileScreen`)

Halaman profil administrator:

#### Informasi Profil
- Avatar dengan initial
- Nama: Budi Santoso
- Role: Administrator

#### Menu Settings
1. **Pengaturan Akun** - Konfigurasi akun admin
2. **ML Analytics** - Shortcut ke analitik ML
3. **Mode Gelap** - Toggle dark mode (dengan switch)
4. **Bantuan & Dukungan** - Akses help & support
5. **Keluar** - Logout dengan konfirmasi

#### App Information
- App name: Jawara Marketplace
- Version: 1.0.0

---

## Navigasi

### Bottom Navigation Bar
Admin dashboard menggunakan bottom navigation dengan 4 tab:
1. **Dashboard** 📊 - Dashboard utama dengan statistik
2. **Users** 👥 - User management
3. **ML Analytics** 📈 - Analitik machine learning
4. **Profil** 👤 - Profil admin

---

## Cara Menggunakan

### Login sebagai Admin

1. Buka aplikasi Jawara Marketplace
2. Di halaman login, klik tombol **"Admin"** di bagian Demo Mode
3. Aplikasi akan otomatis mengarahkan ke Admin Dashboard

### Navigasi Antar Fitur

1. Gunakan bottom navigation untuk berpindah antar tab
2. Klik card management di dashboard untuk akses cepat
3. Gunakan back button untuk kembali ke halaman sebelumnya

---

## File Structure

```
lib/screens/
├── admin_main_screen.dart          # Main navigation screen
├── admin_dashboard_screen.dart      # Dashboard utama + User Management + ML Analytics
├── admin_profile_screen.dart        # Profile admin
└── login_screen.dart                # Updated dengan routing admin
```

---

## Teknologi

- **Flutter**: Framework UI
- **Material Design 3**: Design system
- **StatefulWidget**: State management untuk interaktivitas

---

## Color Scheme

- **Primary Blue**: `#2D3FE3` - Warna utama aplikasi
- **Gold/Yellow**: `#FFD700` - Aksen dan highlight
- **Purple**: Untuk Admin badge
- **Green**: Untuk status aktif dan metrics positif
- **Red**: Untuk status suspended dan logout

---

## Responsive Design

Semua screen dirancang responsive dengan:
- SafeArea untuk menghindari notch
- SingleChildScrollView untuk konten panjang
- GridView.count untuk layout kartu
- Flexible widgets untuk adaptasi ukuran layar

---

## Future Enhancements

1. **Backend Integration**: Koneksi dengan API untuk data real-time
2. **Real-time Updates**: WebSocket untuk notifikasi live
3. **Advanced Analytics**: Grafik interaktif dengan charts library
4. **Bulk Actions**: Aksi massal untuk user management
5. **Export Features**: Export data ke PDF/Excel
6. **Push Notifications**: Notifikasi untuk laporan penting
7. **Search & Filter**: Fitur pencarian dan filter advanced
8. **User Detail**: Halaman detail user dengan riwayat lengkap
9. **RT Management**: CRUD operations untuk RT/RW
10. **Report System**: Sistem laporan dengan approval workflow

---

## Notes

- Saat ini menggunakan data dummy untuk demonstrasi
- Semua statistik adalah hardcoded untuk prototype
- Login admin menggunakan demo mode (tanpa autentikasi)
- Logout mengarahkan kembali ke LoginScreen

---

## Developer

Dashboard admin ini dikembangkan sebagai bagian dari aplikasi Jawara Marketplace untuk memudahkan administrator dalam mengelola komunitas RT/RW dan monitoring sistem AI.
