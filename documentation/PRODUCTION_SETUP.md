# JAWARA MARKETPLACE - PRODUCTION SETUP GUIDE

## ❌ Masalah yang Diperbaiki

### 1. Login Admin & RT/RW Tidak Bekerja
**Penyebab:** Login screen menggunakan demo mode hardcoded, tidak melakukan validasi dengan backend.

**Solusi yang diterapkan:**
- ✅ Mengubah `_handleLogin()` menjadi async function yang melakukan real authentication
- ✅ Menambahkan loading indicator saat login
- ✅ Routing otomatis berdasarkan user_type (admin → Admin Dashboard, rt → RT Dashboard, warga → Warga Home)
- ✅ Error handling dan user feedback

### 2. Database Hanya Demo, Bukan Production
**Penyebab:** Tidak ada script setup untuk production database dengan data real.

**Solusi yang diterapkan:**
- ✅ Membuat `setup_production.php` untuk Windows/XAMPP
- ✅ Membuat `setup_production.sh` untuk Linux/Mac
- ✅ Script otomatis run semua migrations
- ✅ Verify semua tables terbuat dengan benar

---

## 🚀 Cara Setup Database Production

### Untuk Windows (XAMPP)

1. **Copy file setup ke backend folder:**
   ```
   setup_production.php
   ```

2. **Jalankan via CLI:**
   ```cmd
   cd d:\CloneGithub\New_PBL_Jawara\pbl_new\backend
   php setup_production.php
   ```

3. **Output yang diharapkan:**
   ```
   ✅ Database created successfully
   ✅ Executed: migrations/01_auth_users.sql
   ✅ Executed: migrations/02_products_categories.sql
   ... (semua migrations)
   ✅ Database production ready!
   ```

### Untuk Linux/Mac

1. **Set permission:**
   ```bash
   chmod +x setup_production.sh
   ```

2. **Jalankan script:**
   ```bash
   cd pbl_new/backend
   ./setup_production.sh
   ```

---

## 📋 Default Credentials (Seed Data)

### Admin
```
Email: admin@jawara.com
Password: password123
```

### RT/RW Officers
```
Email: ahmad.rt01@jawara.com | Password: password123
Email: budi.rt02@jawara.com | Password: password123
Email: candra.rt03@jawara.com | Password: password123
Email: dedi.rt04@jawara.com | Password: password123
Email: budi.rt05@jawara.com | Password: password123
```

### Sample Warga
```
Email: lisa@jawara.com | Password: password123
Email: dimas@jawara.com | Password: password123
Email: sari@jawara.com | Password: password123
Email: aminah@jawara.com | Password: password123
```

---

## ✅ Checklist Login Real

- [ ] Database sudah di-setup via `setup_production.php` atau `setup_production.sh`
- [ ] Backend PHP API running (`http://localhost/jawara/backend/auth.php`)
- [ ] Flutter ApiConfig.dart menunjuk ke backend yang benar
- [ ] Login dengan credentials di atas berhasil
- [ ] Admin masuk ke Admin Dashboard
- [ ] RT/RW masuk ke RT Dashboard
- [ ] Warga masuk ke Warga Home

---

## 🔧 Struktur Database Production

```
marketplace_rtrw
├── users (14 seed records)
│   └── id, name, email, password (hashed), phone, address, rt, rw, user_type, status
├── products
│   └── id, seller_id, name, description, price, category_id, image_url
├── categories
│   └── id, name, description, icon_url
├── chat_messages
│   └── id, sender_id, receiver_id, message, timestamp
├── transactions
│   └── id, buyer_id, seller_id, product_id, amount, status
├── ml_detections
│   └── id, user_id, image_url, detected_items, confidence, timestamp
├── rt_metrics_activities
│   └── id, rt, rw, metric_name, value, timestamp
```

---

## 🐛 Troubleshooting

### Login Gagal
1. Pastikan backend API accessible: `http://localhost/jawara/backend/auth.php`
2. Check database credentials di `backend/config.php`
3. Pastikan seed data sudah dijalankan (check users table tidak kosong)

### Database Tidak Terbuat
1. Check MySQL/MariaDB running
2. Pastikan root password benar di `setup_production.php`
3. Run manual: `mysql -u root -p < migrations/01_auth_users.sql`

### User Type Redirect Salah
1. Check user_type di database (`SELECT * FROM users WHERE email='admin@jawara.com'`)
2. Pastikan AdminMainScreen, RtMainScreen imported dengan benar

---

## 📝 Files Changed

- `lib/features/auth/screens/login_screen.dart` - Real login implementation
- `lib/core/services/auth_service.dart` - Already had login method (no change needed)
- `backend/setup_production.php` - NEW: Production database setup
- `backend/setup_production.sh` - NEW: Linux/Mac setup script

