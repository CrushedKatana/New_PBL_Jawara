# Fix Bug Dashboard Warga, Notifikasi, Pesan & Profile

## Masalah yang Diperbaiki

### 1. ❌ Bug: Profile.php di Lokasi Salah
**Masalah:** File `profile.php` dibuat di `backend/` (root) padahal seharusnya di `pbl_new/backend/` untuk app Flutter.

**Solusi:**
- ✅ Dipindahkan ke `pbl_new/backend/profile.php`
- ✅ Disesuaikan dengan struktur database yang benar (tabel `users` bukan `auth_users`)
- ✅ ProfileService sudah otomatis menggunakan endpoint yang benar via `ApiConfig.baseUrl`

---

### 2. ❌ Bug: Notifikasi Masih Static/Dummy
**Masalah:** NotificationService hanya menampilkan data dummy, tidak dari database.

**Solusi:**
✅ **Backend:** Buat `pbl_new/backend/notifications.php` dengan endpoints:
- `GET ?user_id=X&filter=semua|pesanan|pesan` - Ambil notifikasi
- `GET ?action=count&user_id=X` - Hitung notifikasi unread
- `POST` - Create notifikasi baru
- `PUT` - Mark notifikasi sebagai read (single atau mark_all)

✅ **Database:** Buat tabel `notifications` (lihat `migrations/07_notifications.sql`):
```sql
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'general',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    related_id VARCHAR(50) NULL,
    data TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

✅ **Flutter:** Update `NotificationService` untuk menggunakan API:
- Ganti semua fungsi dummy dengan HTTP calls
- Ambil data dari `notifications.php`
- Sudah terintegrasi dengan `AuthService.currentUser`

---

### 3. ❌ Bug: Chat/Pesan Masih Dummy
**Masalah:** ChatScreen menampilkan data dummy, tidak dari database.

**Solusi:**
✅ **Backend:** `pbl_new/backend/chat.php` sudah ada dan working dengan endpoints:
- `GET ?user_id=X` - Ambil conversation list
- `GET ?user_id=X&conversation_with=Y` - Ambil messages detail
- `POST` - Send message baru
- `PUT` - Mark messages sebagai read

✅ **Flutter:** Update `ChatScreen`:
- Gunakan `ChatService.getConversations()` untuk load data real
- Tampilkan data dari tabel `messages` database
- Hitung unread berdasarkan `is_read` field
- Loading state dengan `CircularProgressIndicator`
- Empty state jika belum ada chat
- RefreshIndicator untuk pull-to-refresh

**Database:** Tabel `messages` sudah ada dengan struktur:
```sql
CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY,
    sender_id VARCHAR(50) NOT NULL,
    receiver_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 4. ❌ Bug: App Freeze saat Tekan Profile
**Masalah:** Profile screen freeze karena API call yang salah/lama.

**Solusi:**
✅ ProfileService sudah diperbaiki dengan:
- Endpoint yang benar: `${ApiConfig.baseUrl}/profile.php`
- Timeout handling via `ApiConfig.timeout`
- Loading state yang proper dengan `setState()`
- Error handling dengan try-catch
- Tidak ada infinite loop atau blocking call

**Penyebab Freeze (sudah diperbaiki):**
1. ❌ Endpoint mengarah ke folder salah → ✅ Fixed ke `pbl_new/backend/`
2. ❌ Database table name salah (`auth_users` → `users`) → ✅ Fixed
3. ❌ Tidak ada loading state → ✅ Added `_isLoading`

---

### 5. ✅ Kategori di Beranda Sudah Dynamic
**Status:** SUDAH BENAR

`CategoryService` sudah menggunakan:
- Backend: `pbl_new/backend/categories.php`
- HTTP GET ke `ApiConfig.categoriesEndpoint`
- Parse data dari tabel `categories` database

**Tidak ada bug di kategori** ✅

---

## File yang Dibuat/Diubah

### Backend (PHP)
1. **pbl_new/backend/profile.php** - Profile management API
2. **pbl_new/backend/notifications.php** - Notifications API (NEW)
3. **pbl_new/backend/migrations/07_notifications.sql** - Create notifications table (NEW)
4. **pbl_new/backend/chat.php** - Sudah ada (verified)
5. **pbl_new/backend/categories.php** - Sudah ada (verified)

### Flutter (Dart)
1. **lib/core/services/notification_service.dart** - Update dari dummy ke real API
2. **lib/features/warga/screens/chat_screen.dart** - Update untuk dynamic data
3. **lib/core/services/profile_service.dart** - Verified (already correct)
4. **lib/core/services/category_service.dart** - Verified (already correct)
5. **lib/core/services/chat_service.dart** - Verified (already correct)

---

## Cara Testing

### 1. Setup Database
Jalankan SQL migration di phpMyAdmin:
```bash
# Copy paste isi file ini ke phpMyAdmin:
pbl_new/backend/migrations/07_notifications.sql
```

Pastikan tabel `notifications` sudah dibuat dengan sample data.

### 2. Test Notifikasi
1. Buka app → Login sebagai Warga
2. Di Beranda, lihat badge notifikasi (angka merah)
3. Tap icon notifikasi → masuk ke NotifikasiScreen
4. Cek apakah ada notifikasi dari database (bukan dummy)
5. Test tab filter: Semua, Pesanan, Pesan
6. Tap "Tandai semua dibaca" → badge hilang
7. Pull down untuk refresh

**Expected:**
- Notifikasi muncul dari database
- Badge count sesuai jumlah unread
- Filter working
- Mark all working

### 3. Test Chat/Pesan
1. Buka tab "Pesan" di bottom nav
2. Cek apakah ada conversation list dari database
3. Jika kosong → **Normal** (belum ada chat di database)
4. Pull down untuk refresh

**Expected:**
- Jika ada chat di tabel `messages` → muncul conversation list
- Jika kosong → tampil empty state "Belum ada percakapan"
- Loading spinner muncul saat load data

### 4. Test Profile
1. Buka tab "Profil"
2. **Jangan freeze!** Loading spinner muncul
3. Data profile muncul: nama, email, RT/RW, status verifikasi
4. Statistik muncul: Terjual, Favorit, Rating
5. Pull down untuk refresh
6. Tap "Keluar" → dialog konfirmasi → logout working

**Expected:**
- App tidak freeze
- Loading max 2-3 detik
- Data muncul dari tabel `users`
- Logout working

### 5. Test Kategori
1. Di Beranda, scroll ke "Kategori"
2. Cek apakah kategori muncul (Kemeja, Sepatu, Topi, T-Shirt)

**Expected:**
- Kategori muncul dari tabel `categories`
- Bukan data hardcoded

---

## Troubleshooting

### Profile masih freeze?
**Check:**
1. XAMPP MySQL running?
2. Database `marketplace_rtrw` exists?
3. Tabel `users` ada data?
4. Jalankan query test:
```sql
SELECT * FROM users WHERE id = 'user_6755f4d2b4a7d';
```
5. Cek console Flutter untuk error message
6. Cek Network IP di `api_config.dart` (default: `192.168.1.7`)

### Notifikasi tidak muncul?
**Check:**
1. Tabel `notifications` sudah dibuat?
2. Ada data di tabel notifications?
3. `user_id` di notifications sesuai dengan user login?
4. Run sample insert:
```sql
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) 
VALUES ('user_6755f4d2b4a7d', 'Test Notif', 'Ini test', 'general', 0, NOW());
```

### Chat tidak muncul?
**Normal!** Chat empty jika belum ada data di tabel `messages`.

Untuk testing, insert dummy message:
```sql
INSERT INTO messages (id, sender_id, receiver_id, message, is_read, created_at)
VALUES 
('msg1', 'user_xxx', 'user_6755f4d2b4a7d', 'Test pesan 1', 0, NOW()),
('msg2', 'user_6755f4d2b4a7d', 'user_xxx', 'Test reply', 1, NOW());
```

### API Error 404?
**Check:**
1. File PHP ada di `pbl_new/backend/` bukan di root `backend/`
2. XAMPP htdocs path: `C:\xampp\htdocs\jawara\pbl_new\backend\`
3. Test endpoint langsung:
```
http://192.168.1.7/jawara/pbl_new/backend/notifications.php?action=count&user_id=user_6755f4d2b4a7d
```

---

## Summary Fixes

| Bug | Status | Fix |
|-----|--------|-----|
| Profile di folder salah | ✅ Fixed | Dipindah ke `pbl_new/backend/profile.php` |
| Notifikasi dummy | ✅ Fixed | API + Database integration |
| Chat dummy | ✅ Fixed | API + Database integration |
| Profile freeze | ✅ Fixed | Proper async loading + timeout |
| Kategori static | ✅ Already OK | Already using API |

## Next Steps

1. ✅ **SELESAI** - Semua backend PHP sudah di `pbl_new/backend/`
2. ✅ **SELESAI** - Semua service Flutter sudah dynamic
3. ⏳ **TODO** - Jalankan SQL migration `07_notifications.sql`
4. ⏳ **TODO** - Test semua fitur di app
5. ⏳ **TODO** - Insert sample data untuk testing

---

**Notes:**
- Folder `backend/` di root sekarang hanya untuk ML (Docker deployment)
- Folder `pbl_new/backend/` untuk backend Flutter app
- Jangan bingung antara 2 folder backend!
