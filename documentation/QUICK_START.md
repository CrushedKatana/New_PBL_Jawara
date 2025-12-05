# 🚀 QUICK START - PRODUCTION LOGIN & DATABASE

## ⚡ 5-Minute Setup

### 1. Setup Database (1 min)
```cmd
cd d:\CloneGithub\New_PBL_Jawara\pbl_new\backend
php setup_production.php
```
✅ Done! 14 seed users created

### 2. Start XAMPP (1 min)
- Open XAMPP Control Panel
- Start Apache
- Start MySQL

### 3. Run Flutter App (2 min)
```bash
cd d:\CloneGithub\New_PBL_Jawara\pbl_new
flutter run
```

### 4. Test Login (1 min)
Use any credentials below with password `password123`

---

## 🔑 Login Credentials

| Role | Email | Password | Expected Dashboard |
|------|-------|----------|-------------------|
| **Admin** | `admin@jawara.com` | `password123` | Admin Dashboard |
| **RT 01** | `ahmad.rt01@jawara.com` | `password123` | RT Dashboard |
| **RT 02** | `budi.rt02@jawara.com` | `password123` | RT Dashboard |
| **RT 03** | `candra.rt03@jawara.com` | `password123` | RT Dashboard |
| **RT 04** | `dedi.rt04@jawara.com` | `password123` | RT Dashboard |
| **RT 05** | `budi.rt05@jawara.com` | `password123` | RT Dashboard |
| **Warga** | `lisa@jawara.com` | `password123` | Warga Home |
| **Warga** | `dimas@jawara.com` | `password123` | Warga Home |
| **Warga** | `sari@jawara.com` | `password123` | Warga Home |
| **Warga** | `aminah@jawara.com` | `password123` | Warga Home |

---

## 🔧 Configuration

### API Endpoint
**File:** `lib/config/api_config.dart`

**Default (Local XAMPP):**
```dart
static const String baseUrl = 'http://localhost/jawara/backend';
```

**Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2/jawara/backend';
```

**Physical Device (replace IP):**
```dart
static const String baseUrl = 'http://192.168.1.100/jawara/backend';
```

---

## ✅ Verify Setup

### Backend Accessibility
```bash
curl -X POST http://localhost/jawara/backend/auth.php \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@jawara.com","password":"password123"}'
```

Should return user data (not error)

### Database Status
```bash
mysql -u root
> USE marketplace_rtrw;
> SELECT COUNT(*) FROM users;
```

Should show: `14`

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Check XAMPP running, baseUrl correct |
| "User not found" | Run setup_production.php again |
| "Password incorrect" | Use `password123`, check hashing |
| "Empty dashboard" | Check API endpoint working |
| Login still uses demo | Rebuild Flutter app: `flutter clean && flutter run` |

---

## 📚 Full Documentation

- **Setup Details:** `PRODUCTION_SETUP.md`
- **Testing Guide:** `TESTING_LOGIN_GUIDE.md`
- **All Fixes:** `FIX_SUMMARY.md`

---

## 🎯 What's Fixed

✅ Admin login now goes to Admin Dashboard  
✅ RT/RW login now goes to RT Dashboard  
✅ Warga login now goes to Warga Home  
✅ Real authentication (not hardcoded demo)  
✅ Production database setup automation  
✅ 14 seed users for testing all roles  
✅ Complete documentation & guides  

**You're ready to go! 🚀**
