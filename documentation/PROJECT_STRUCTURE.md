# 📂 Struktur Project PBL Jawara - Clean & Organized

## ✅ Reorganisasi Selesai (Dec 13, 2025)

Folder `backend/` di root **SUDAH DIHAPUS** untuk menghindari kebingungan.
Semua backend sekarang terorganisir dengan jelas!

---

## 📁 Struktur Folder Utama

```
New_PBL_Jawara/
│
├── 📱 pbl_new/                        # FLUTTER APP PROJECT
│   ├── lib/                           # Flutter source code
│   │   ├── main.dart
│   │   ├── config/api_config.dart
│   │   ├── core/                      # Models, services
│   │   └── features/                  # Screens (warga, RT, admin)
│   │
│   ├── 🔧 backend/                    # PHP BACKEND untuk Flutter App
│   │   ├── config.php                 # Database connection
│   │   ├── auth.php                   # Login/Register
│   │   ├── profile.php                # User profile ✅ FIXED
│   │   ├── notifications.php          # Notifications ✅ NEW
│   │   ├── chat.php                   # Chat/Messages
│   │   ├── products.php               # Products CRUD
│   │   ├── categories.php             # Categories
│   │   ├── users.php                  # User management
│   │   ├── transactions.php           # Transactions
│   │   ├── rt_metrics.php             # RT metrics
│   │   └── migrations/                # Database SQL files
│   │       ├── 01_auth_users.sql
│   │       ├── 02_products_categories.sql
│   │       ├── 03_chat_messages.sql
│   │       ├── 04_transactions.sql
│   │       ├── 05_ml_detections.sql
│   │       ├── 06_rt_metrics_activities.sql
│   │       └── 07_notifications.sql   ✅ NEW
│   │
│   └── android/, ios/, web/, ...      # Platform files
│
├── 🤖 huggingface_deployment/         # ML MODEL DEPLOYMENT
│   ├── app.py                         # Hugging Face Space main app
│   ├── clothing-detection/            # Model files ✅ MOVED HERE
│   │   ├── ml_api_docker.py           # Docker API
│   │   ├── Dockerfile                 # Docker config
│   │   ├── clothing_svm_best.pkl      # SVM model
│   │   └── clothing_scaler_best.pkl   # Scaler
│   ├── label_mapping.json             # Category labels
│   ├── requirements.txt               # Python dependencies
│   └── DEPLOYMENT_GUIDE.md            # Deploy docs
│
├── 📊 ml_training/                    # ML TRAINING SCRIPTS
│   └── training notebooks, datasets
│
├── 📚 documentation/                  # PROJECT DOCUMENTATION
│   └── various .md files
│
└── 📝 Root Documentation Files
    ├── README.md                      # Main project readme
    ├── BUG_FIX_SUMMARY.md            # Bug fixes done
    ├── BACKEND_ARCHITECTURE.md        # Backend explanation
    ├── REORGANIZATION_COMPLETE.md     # This reorganization
    └── USERS_CREDENTIALS.md           # Test users
```

---

## 🎯 Fungsi Setiap Folder Backend

### 1. `pbl_new/backend/` - Backend Flutter App
**Teknologi:** PHP + MySQL (XAMPP)
**URL:** `http://192.168.1.7/jawara/pbl_new/backend/`

**Untuk:**
- Authentication (login/register)
- User profile management
- Products & categories
- Chat/messaging
- Notifications
- Transactions
- RT metrics & activities

**Akses dari Flutter:**
```dart
ApiConfig.baseUrl // Otomatis mengarah ke pbl_new/backend/
```

---

### 2. `huggingface_deployment/` - ML Deployment
**Teknologi:** Python + Flask + scikit-learn
**URL:** `https://crushedkatana-clothing-detection.hf.space/detect`

**Untuk:**
- Clothing detection ML model
- HOG + SVM classification
- 4 categories: Topi, Kemeja, Sepatu, T-Shirt
- Deployed to Hugging Face Spaces

**Akses dari Flutter:**
```dart
ApiConfig.mlDetectionEndpoint // Hugging Face endpoint
```

---

## ✅ Yang BERUBAH (Reorganisasi)

### ❌ SEBELUM:
```
backend/                      # ❌ Folder ini membingungkan!
├── profile.php              # ❌ Salah tempat!
└── clothing-detection/      # ML stuff

pbl_new/backend/             # Backend Flutter yang benar
```

### ✅ SETELAH:
```
[backend/ DIHAPUS]           # ✅ Tidak ada lagi!

pbl_new/backend/             # ✅ Semua PHP untuk Flutter
├── profile.php              # ✅ Di tempat yang benar
├── notifications.php        # ✅ NEW
└── ...

huggingface_deployment/      # ✅ Semua ML stuff
├── app.py
└── clothing-detection/      # ✅ Dipindah ke sini
```

---

## 🚀 Quick Start Guide

### 1. Setup Flutter App
```bash
cd pbl_new
flutter pub get
flutter run
```

### 2. Setup Backend PHP (XAMPP)
1. Copy `pbl_new/backend/` ke `C:\xampp\htdocs\jawara\pbl_new\backend\`
2. Import database: `pbl_new/backend/database.sql`
3. Run migrations: Execute SQL files in `migrations/` folder
4. Start XAMPP: Apache + MySQL
5. Test: `http://localhost/jawara/pbl_new/backend/auth.php`

### 3. Test ML Deployment
- URL: https://crushedkatana-clothing-detection.hf.space/detect
- Already deployed on Hugging Face Spaces
- No local setup needed!

---

## 🔍 File Locations Quick Reference

| What | Location | URL |
|------|----------|-----|
| Flutter App | `pbl_new/` | - |
| PHP Backend | `pbl_new/backend/` | `http://192.168.1.7/jawara/pbl_new/backend/` |
| Database SQL | `pbl_new/backend/migrations/` | - |
| ML Model | `huggingface_deployment/` | `https://crushedkatana-clothing-detection.hf.space/` |
| Documentation | `documentation/` + root `*.md` files | - |

---

## 📋 Testing Checklist

After reorganization:
- [x] Folder `backend/` di root dihapus ✅
- [x] ML files dipindah ke `huggingface_deployment/` ✅
- [ ] Flutter app still running
- [ ] Profile screen tidak freeze
- [ ] Notifikasi working
- [ ] Chat working
- [ ] ML detection working

---

## 📞 Troubleshooting

### "Cannot find backend folder"
✅ **Correct location:** `pbl_new/backend/` (NOT root `backend/`)

### "Profile freeze / 404 error"
✅ **Check:** XAMPP running + file ada di `C:\xampp\htdocs\jawara\pbl_new\backend/`

### "ML detection not working"
✅ **Check:** Internet connection (uses Hugging Face API)

---

## 📖 Documentation Files

- `README.md` - Main project overview
- `BUG_FIX_SUMMARY.md` - All bug fixes (notif, chat, profile)
- `BACKEND_ARCHITECTURE.md` - Detailed backend explanation
- `REORGANIZATION_COMPLETE.md` - This reorganization details
- `USERS_CREDENTIALS.md` - Test user accounts

---

**Last Updated:** December 13, 2025
**Status:** ✅ Clean & Organized
**Backend folder at root:** ❌ DELETED (no longer confusing!)
