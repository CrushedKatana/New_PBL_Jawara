# 📱 Profile Settings - Dynamic from Database

## ✅ Fitur yang Sudah Diimplementasi

### 1. **Dynamic Profile Data**
Data profil sekarang diambil dari database secara real-time:

- ✅ Nama user dari database
- ✅ Role (Warga/RT/Admin) dari database
- ✅ Alamat lengkap dari database
- ✅ RT/RW number dari database
- ✅ Status verifikasi dinamis
- ✅ Email dan phone dari database

### 2. **Dynamic Statistics (Warga Only)**
Statistik otomatis dihitung dari database:

- ✅ Total produk terjual
- ✅ Total favorit yang diterima
- ✅ Average rating dari reviews
- ✅ Auto-update saat refresh

### 3. **Logout dengan Konfirmasi**
Semua user (Warga/RT/Admin) sekarang punya:

- ✅ Konfirmasi dialog sebelum logout
- ✅ Logout berfungsi dengan benar
- ✅ Auto redirect ke login screen
- ✅ Clear session data

### 4. **Pull to Refresh**
Semua profil screen bisa di-refresh:

- ✅ Pull down untuk reload data
- ✅ Loading indicator
- ✅ Auto update terbaru

---

## 📁 File yang Ditambahkan/Diupdate

### Backend PHP
```
backend/profile.php
```
**Endpoints:**
- `get_profile` - Get user profile data
- `update_profile` - Update user info
- `get_stats` - Get user statistics

### Flutter Service
```
lib/core/services/profile_service.dart
```
**Methods:**
- `getUserProfile(userId)` - Fetch profile from DB
- `updateProfile(...)` - Update user data
- `getUserStats(userId)` - Get statistics

### Profile Screens (Updated)
1. `lib/features/warga/screens/profil_screen.dart`
   - Dynamic data from database
   - Statistics integration
   - Logout confirmation
   - Pull to refresh

2. `lib/features/rt/screens/rt_profil_screen.dart`
   - Dynamic RT number display
   - Database integration
   - Logout confirmation

3. `lib/features/admin/screens/admin_profile_screen.dart`
   - Dynamic admin data
   - Logout confirmation
   - Statistics (if applicable)

---

## 🚀 Cara Menggunakan

### Untuk Warga

1. **Lihat Profil:**
   - Buka tab "Profil" dari bottom navigation
   - Data otomatis load dari database
   - Statistik terjual/favorit/rating ditampilkan

2. **Refresh Data:**
   - Pull down layar untuk refresh
   - Data akan reload dari database

3. **Logout:**
   - Tap tombol "Keluar" (merah)
   - Konfirmasi di dialog
   - Auto redirect ke login

### Untuk RT

1. **Lihat Profil:**
   - RT number otomatis ditampilkan
   - Data wilayah dari database

2. **Logout:**
   - Sama seperti warga

### Untuk Admin

1. **Lihat Profil:**
   - Nama dan role admin ditampilkan
   - Data dari database

2. **Logout:**
   - Konfirmasi logout
   - Clear session
   - Redirect ke login

---

## 🔧 API Endpoints

### 1. Get Profile
```http
POST http://192.168.1.7/jawara/backend/profile.php
```
**Body:**
```
action=get_profile
user_id=1
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "081234567890",
    "address": "Jl. Merdeka No. 123",
    "role": "warga",
    "rt_number": "05",
    "rw_number": "02",
    "is_verified": 1,
    "profile_image": null
  }
}
```

### 2. Update Profile
```http
POST http://192.168.1.7/jawara/backend/profile.php
```
**Body:**
```
action=update_profile
user_id=1
name=John Updated
phone=081999999999
address=Jl. Baru No. 456
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

### 3. Get Statistics
```http
POST http://192.168.1.7/jawara/backend/profile.php
```
**Body:**
```
action=get_stats
user_id=1
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_products": 5,
    "total_sold": 12,
    "total_favorites": 28,
    "avg_rating": 4.8
  }
}
```

---

## 📊 Database Schema (Required Tables)

### auth_users
```sql
- id (PRIMARY KEY)
- name
- email
- phone
- address
- role (warga/rt/admin)
- rt_number
- rw_number
- is_verified (0/1)
- profile_image
- created_at
```

### products (for statistics)
```sql
- id
- seller_id (FK to auth_users)
- title
- price
- ...
```

### transactions (for sold count)
```sql
- id
- product_id (FK to products)
- status ('completed')
- ...
```

### products_favorites (for favorites)
```sql
- id
- user_id
- product_id
```

### product_reviews (for ratings)
```sql
- id
- product_id
- rating (1-5)
- ...
```

---

## 🔒 Security Features

1. **User ID Validation:**
   - All requests require valid user_id
   - Backend validates user exists

2. **Session Management:**
   - Logout clears local storage
   - Session removed from SharedPreferences
   - No lingering data

3. **Confirmation Dialogs:**
   - Prevents accidental logout
   - Clear action buttons

---

## 🐛 Troubleshooting

### Data Tidak Muncul
```dart
// Check console logs
🔍 Loading profile data...
✅ Profile loaded: {...}
```

**Fix:**
- Pastikan backend profile.php sudah di deploy
- Check XAMPP running
- Verify database connection

### Logout Tidak Bekerja
```dart
// Check logout confirmation
Navigator.pushReplacementNamed(context, '/login');
```

**Fix:**
- Pastikan route '/login' terdaftar
- Check AuthService.logout() dipanggil
- Verify SharedPreferences cleared

### Statistics 0 Semua
**Normal jika:**
- User baru belum ada transaksi
- Belum ada produk yang dijual
- Belum ada favorit

**Fix:**
- Test dengan user yang sudah punya data
- Insert dummy data di database

---

## ✨ Fitur Mendatang (Future Enhancement)

- [ ] Edit profile inline (tap name to edit)
- [ ] Upload profile photo
- [ ] Change password dari profil
- [ ] Activity history
- [ ] Notifikasi settings
- [ ] Privacy settings
- [ ] Export data user

---

## 📝 Testing Checklist

### Warga Profile
- [x] Data nama dari DB
- [x] Alamat dari DB
- [x] RT/RW number displayed
- [x] Status verifikasi (Terverifikasi/Pending)
- [x] Statistics (Terjual/Favorit/Rating)
- [x] Pull to refresh works
- [x] Logout dengan konfirmasi
- [x] Redirect ke login after logout

### RT Profile
- [x] Data nama dari DB
- [x] RT number displayed
- [x] Logout works
- [x] Pull to refresh

### Admin Profile
- [x] Data nama dari DB
- [x] Role admin displayed
- [x] Logout works
- [x] No crash on logout

---

## 🎉 Hasil

✅ **Semua User (Warga/RT/Admin):**
- Data profil dinamis dari database
- Logout berfungsi dengan konfirmasi
- Pull to refresh untuk update data
- Loading state dengan spinner
- Error handling graceful

✅ **No More Static Data:**
- Semua data real-time dari MySQL
- Auto-update saat data berubah
- Konsisten across all users

✅ **Production Ready:**
- Tested di 3 role berbeda
- Error handling complete
- UI/UX smooth dengan loading states
