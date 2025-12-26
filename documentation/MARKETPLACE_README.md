# Jawara Marketplace - Aplikasi Marketplace RT/RW

Aplikasi marketplace lokal untuk warga RT/RW untuk jual-beli pakaian dan aksesoris.

## Fitur Utama

### 1. **Halaman Beranda**
- Search bar untuk mencari produk
- Kategori produk (T-Shirt, Kemeja, Topi, Sepatu, Jaket)
- List produk terbaru dengan status "Baru"
- Filter berdasarkan kategori
- Notifikasi

### 2. **Halaman Jualan Saya**
- Statistik produk (Aktif, Pending, Terjual)
- Tambah produk baru dengan fitur:
  - Upload foto dari kamera atau galeri
  - Deteksi kategori otomatis dengan PCVK (Point Cloud Vision Kit)
  - Form lengkap (nama, kategori, harga, ukuran, kondisi, deskripsi)
- Tab view untuk produk Aktif, Pending, dan Terjual
- Edit dan hapus produk
- View count dan chat count untuk setiap produk

### 3. **Halaman Chat/Pesan**
- List percakapan dengan seller/buyer
- Badge unread message
- Real-time messaging
- Timestamp pesan
- Status online seller
- Verified badge untuk user terverifikasi

### 4. **Halaman Profil**
- Informasi user (nama, RT/RW, status verifikasi)
- Statistik (Terjual, Favorit, Rating)
- Pengaturan akun
- Mode gelap
- Bantuan & dukungan
- Logout

### 5. **Detail Produk**
- Gallery foto produk (swipe)
- Informasi lengkap produk
- Informasi seller dengan verified badge
- Tombol Chat dan Hubungi
- Share dan Favorite

## Teknologi yang Digunakan

- **Flutter** - Framework aplikasi mobile
- **Firebase Authentication** - Autentikasi user
- **Cloud Firestore** - Database real-time
- **Firebase Storage** - Penyimpanan gambar
- **Image Picker** - Ambil foto dari kamera/galeri
- **Provider** - State management
- **Intl** - Format currency dan date

## Struktur Proyek

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── message_model.dart
│   └── category_model.dart
├── screens/          # Halaman aplikasi
│   ├── beranda_screen.dart
│   ├── jualan_screen.dart
│   ├── chat_screen.dart
│   ├── chat_detail_screen.dart
│   ├── profil_screen.dart
│   ├── product_detail_screen.dart
│   └── add_product_screen.dart
├── services/         # Firebase services
│   ├── auth_service.dart
│   ├── product_service.dart
│   └── chat_service.dart
├── widgets/          # Reusable widgets
│   └── product_card.dart
├── firebase_options.dart
└── main.dart
```

## User Roles

1. **Warga** - User biasa yang bisa:
   - Jual dan beli produk
   - Chat dengan seller/buyer
   - Mendapatkan verified badge

## Fitur Firebase

### Firestore Collections:
- `users` - Data user
- `products` - Data produk
- `chats` - Data percakapan
  - `messages` - Subcollection untuk pesan

### Storage:
- `products/` - Foto produk

## Setup & Instalasi

1. Clone repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Konfigurasi Firebase:
   - Sudah dikonfigurasi untuk project `pbljawara`
   - File `firebase_options.dart` sudah tersedia

4. Run aplikasi:
   ```bash
   flutter run
   ```

## Permissions (Android)

- INTERNET - Untuk koneksi Firebase
- CAMERA - Untuk ambil foto produk
- READ_EXTERNAL_STORAGE - Untuk akses galeri
- WRITE_EXTERNAL_STORAGE - Untuk simpan foto

## Design Color Scheme

- Primary: `#2D3FE3` (Blue)
- Accent: `#FFC107` (Yellow untuk badge "Baru")
- Background: `#F5F5F5` (Grey)
- Card: `#FFFFFF` (White)

## Status Produk

- **Aktif** - Produk tersedia untuk dijual
- **Pending** - Produk menunggu persetujuan/verifikasi
- **Terjual** - Produk sudah terjual

## Bottom Navigation

1. Beranda - Icon: home
2. Jualan - Icon: shopping_bag
3. Chat - Icon: chat_bubble
4. Profil - Icon: person

## Developed By

Tim PBL Jawara - 2025
