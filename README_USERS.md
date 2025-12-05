# 📋 README: Daftar User & Password Testing

Sudah dibuat file lengkap berisi daftar semua user untuk testing aplikasi Jawara Marketplace.

## 📄 File yang Dibuat

### 1. **USERS_CREDENTIALS.md** (LOCAL ONLY - Jangan di-commit)
   - File ini berisi kredensial lengkap untuk semua user
   - **LOKASI:** `d:\CloneGithub\New_PBL_Jawara\USERS_CREDENTIALS.md`
   - **SECURITY:** Sudah di-exclude dari git (di .gitignore)
   - Jangan commit ke repository public!

### 2. **test_users.bat** (Windows Testing Script)
   - Script untuk test login semua user
   - **LOKASI:** `d:\CloneGithub\New_PBL_Jawara\test_users.bat`
   - **CARA PAKAI:** Double-click atau buka terminal & jalankan `test_users.bat`

### 3. **test_users.sh** (Linux/Mac Testing Script)
   - Script untuk test login di Linux/Mac
   - **LOKASI:** `d:\CloneGithub\New_PBL_Jawara\test_users.sh`
   - **CARA PAKAI:** `chmod +x test_users.sh && ./test_users.sh`

### 4. **.gitignore** (Updated)
   - Sudah di-update untuk exclude credentials files
   - Proteksi: `USERS_CREDENTIALS.md`, `.env`, `secrets.json`, dll

---

## 👥 Daftar User (14 Total)

### Admin (1 user)
```
Email: admin@jawara.com
Password: Admin@123456
Role: Administrator
```

### RT/RW (5 users)
```
rt1@jawara.com / RT@123456
rt2@jawara.com / RT@123456
rt3@jawara.com / RT@123456
rt4@jawara.com / RT@123456
rt5@jawara.com / RT@123456
```

### Warga (8 users)
```
warga1@jawara.com / Warga@123456
warga2@jawara.com / Warga@123456
warga3@jawara.com / Warga@123456
warga4@jawara.com / Warga@123456
warga5@jawara.com / Warga@123456
warga6@jawara.com / Warga@123456
warga7@jawara.com / Warga@123456
warga8@jawara.com / Warga@123456
```

---

## 🧪 Cara Testing

### Metode 1: Login Manual di App
1. Buka app Jawara di Android
2. Click "Login"
3. Masukkan email (contoh: `admin@jawara.com`)
4. Masukkan password (contoh: `Admin@123456`)
5. Click "Login"

### Metode 2: Test via Script (Windows)
```bash
# Open terminal di folder project
cd d:\CloneGithub\New_PBL_Jawara
test_users.bat
```

### Metode 3: Test via cURL (Manual)
```bash
curl -X POST http://localhost/jawara/backend/auth.php \
  -H "Content-Type: application/json" \
  -d '{
    "action": "login",
    "email": "admin@jawara.com",
    "password": "Admin@123456"
  }'
```

---

## 🔍 Testing Checklist

- [ ] Admin login berhasil
- [ ] Admin bisa akses Admin Dashboard
- [ ] RT login berhasil
- [ ] RT bisa akses RT Dashboard
- [ ] Warga login berhasil
- [ ] Warga bisa akses Marketplace
- [ ] Role-based access bekerja
- [ ] Firebase Messaging terintegrasi
- [ ] Real-time updates bekerja
- [ ] Camera detection bekerja
- [ ] Chat messaging bekerja

---

## ⚠️ PENTING: Security Reminders

### ❌ JANGAN:
- ❌ Commit USERS_CREDENTIALS.md ke public repository
- ❌ Share passwords di public channels
- ❌ Gunakan passwords ini di production
- ❌ Hardcode credentials di source code

### ✅ HARUS:
- ✅ Keep credentials file locally only
- ✅ Change all passwords sebelum production
- ✅ Use environment variables untuk production credentials
- ✅ Implement proper authentication (OAuth, JWT, dll)
- ✅ Enable HTTPS di production
- ✅ Setup 2FA untuk admin accounts

---

## 📚 Referensi File

| File | Purpose | Location |
|------|---------|----------|
| USERS_CREDENTIALS.md | Complete user list & testing guide | Project Root (Local Only) |
| test_users.bat | Windows testing script | Project Root |
| test_users.sh | Linux/Mac testing script | Project Root |
| .gitignore | Exclude sensitive files | Project Root |
| BUILD_STATUS.md | Build & deployment status | Project Root |

---

## 🚀 Next Steps

1. **Open USERS_CREDENTIALS.md** untuk melihat detail lengkap
2. **Run test_users.bat** untuk test semua user via API
3. **Login ke app** dengan credentials dari file
4. **Test semua features** sesuai user role
5. **Document issues** yang ditemukan

---

**Status:** ✅ Ready for Testing  
**Date:** December 5, 2025  
**Total Users:** 14

Semua file sudah siap untuk testing! 🎉
