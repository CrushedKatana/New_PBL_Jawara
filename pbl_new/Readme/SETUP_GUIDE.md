# Setup Guide - Jawara Marketplace

## Prerequisites

1. Flutter SDK (versi 3.9.2 atau lebih tinggi)
2. Android Studio atau VS Code
3. Firebase CLI
4. Git

## Setup Firebase

Aplikasi ini sudah terhubung dengan Firebase project `pbljawara`. Berikut adalah konfigurasi yang sudah ada:

### Firebase Services yang Digunakan:
- ✅ Firebase Authentication
- ✅ Cloud Firestore
- ✅ Firebase Storage

### Platform yang Didukung:
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS

## Instalasi

### 1. Clone Repository
```bash
git clone <repository-url>
cd New_PBL_Jawara/pbl_new
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Android (Jika belum)
Pastikan Android SDK sudah terinstall dan path sudah dikonfigurasi.

```bash
flutter doctor
```

### 4. Run Aplikasi

#### Debug Mode
```bash
flutter run
```

#### Release Mode (Android)
```bash
flutter build apk --release
flutter install
```

#### Untuk platform lain
```bash
# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## Struktur Database Firestore

### Collection: `users`
```json
{
  "uid": "string",
  "name": "string",
  "role": "warga",
  "rtRw": "RT 05 / RW 02, Kelurahan Maju Jaya",
  "kelurahan": "string",
  "isVerified": false,
  "photoUrl": "string (optional)",
  "productsSold": 0,
  "favoriteCount": 0,
  "rating": 0.0,
  "createdAt": "Timestamp"
}
```

### Collection: `products`
```json
{
  "id": "auto-generated",
  "sellerId": "string",
  "sellerName": "string",
  "sellerRtRw": "string",
  "sellerVerified": false,
  "name": "string",
  "category": "string",
  "price": 0,
  "size": "string (optional)",
  "condition": "string",
  "description": "string",
  "imageUrls": ["array of strings"],
  "status": "aktif|pending|terjual",
  "viewCount": 0,
  "chatCount": 0,
  "isNew": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Collection: `chats`
```json
{
  "id": "userId1_userId2",
  "participants": ["userId1", "userId2"],
  "lastMessage": "string",
  "lastMessageTime": "Timestamp",
  "unreadCount": {
    "userId1": 0,
    "userId2": 0
  },
  "participantsData": {
    "userId1": {
      "name": "string",
      "verified": false
    },
    "userId2": {
      "name": "string",
      "verified": false
    }
  }
}
```

### Subcollection: `chats/{chatId}/messages`
```json
{
  "id": "auto-generated",
  "senderId": "string",
  "receiverId": "string",
  "message": "string",
  "timestamp": "Timestamp",
  "isRead": false
}
```

## Firebase Storage Structure

```
storage/
└── products/
    ├── {sellerId}_{timestamp}_0.jpg
    ├── {sellerId}_{timestamp}_1.jpg
    └── ...
```

## Fitur PCVK (Point Cloud Vision Kit)

Fitur PCVK untuk deteksi kategori otomatis saat user menambahkan produk:
1. User mengambil foto produk dari kamera
2. Sistem akan menganalisa gambar
3. Kategori akan terisi otomatis berdasarkan hasil deteksi

> Note: Untuk implementasi lengkap PCVK, diperlukan integrasi dengan ML Kit atau TensorFlow Lite.

## Testing

### Test User (untuk development)
```
Email: test@jawara.com
Password: test123456
Name: Budi Santoso
RT/RW: RT 05 / RW 02, Kelurahan Maju Jaya
Role: warga
```

### Test Scenarios:

1. **User Registration & Login**
   - Register user baru
   - Login dengan user yang sudah ada
   - Logout

2. **Product Management**
   - Tambah produk baru dengan foto
   - Edit produk
   - Hapus produk
   - Lihat detail produk

3. **Chat/Messaging**
   - Chat dengan seller
   - Kirim pesan
   - Lihat unread messages

4. **Browse & Search**
   - Browse produk di beranda
   - Search produk
   - Filter by kategori

## Troubleshooting

### Error: Firebase not initialized
**Solusi:**
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Error: Permission denied (Camera/Storage)
**Solusi:** Pastikan permissions sudah ditambahkan di `AndroidManifest.xml`

### Error: Image picker tidak berfungsi
**Solusi:** 
1. Check permissions
2. Rebuild aplikasi
3. Test di real device (bukan emulator)

### Error: Firestore rules
**Solusi:** Update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Error: Storage rules
**Solusi:** Update Storage rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Build untuk Production

### Android APK
```bash
flutter build apk --release
```
APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (untuk Google Play)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Environment Variables

Untuk production, sebaiknya gunakan environment variables untuk:
- API Keys
- Firebase Config
- Third-party services

## Contact & Support

Untuk bantuan lebih lanjut, hubungi tim development PBL Jawara.

---

**Version:** 1.0.0  
**Last Updated:** 2025
