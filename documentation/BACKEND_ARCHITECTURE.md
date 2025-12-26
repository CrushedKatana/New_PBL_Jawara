# Penjelasan Arsitektur Folder Backend

## ⚠️ Ada 2 Folder Backend - Jangan Bingung!

### 1. 📁 `backend/` (di root)
**Lokasi:** `D:\CloneGithub\New_PBL_Jawara\backend\`

**Fungsi:** Backend untuk **ML Detection (Machine Learning)**

**Isi:**
```
backend/
├── Dockerfile              # Docker config untuk Hugging Face
├── ml_api_docker.py        # Python API untuk ML detection
├── requirements_docker.txt # Python dependencies
├── docker-compose.yml      # Docker compose config
└── clothing-detection/     # Model ML untuk deteksi pakaian
```

**Digunakan untuk:**
- Deployment ML model ke Hugging Face Space
- Docker containerization
- Python Flask API untuk clothing detection
- TIDAK untuk Flutter app

---

### 2. 📁 `pbl_new/backend/` (di dalam project Flutter)
**Lokasi:** `D:\CloneGithub\New_PBL_Jawara\pbl_new\backend\`

**Fungsi:** Backend untuk **Flutter App (PHP + MySQL)**

**Isi:**
```
pbl_new/backend/
├── config.php              # Database connection
├── auth.php                # Authentication (login/register)
├── products.php            # Product CRUD
├── categories.php          # Category management
├── chat.php                # Chat/messages
├── notifications.php       # Notifications (NEW!)
├── profile.php             # User profile (FIXED!)
├── users.php               # User management
├── transactions.php        # Transactions
├── rt_metrics.php          # RT metrics
├── ml_detection.php        # ML detection proxy
└── migrations/             # Database SQL files
    ├── 01_auth_users.sql
    ├── 02_products_categories.sql
    ├── 03_chat_messages.sql
    ├── 04_transactions.sql
    ├── 05_ml_detections.sql
    ├── 06_rt_metrics_activities.sql
    └── 07_notifications.sql (NEW!)
```

**Digunakan untuk:**
- Flutter app API endpoints
- XAMPP Apache + MySQL
- PHP REST API
- Database migrations

---

## ❌ Kesalahan yang Terjadi

### Saya membuat `profile.php` di folder yang salah:
```
❌ SALAH: backend/profile.php (root folder - untuk ML)
✅ BENAR: pbl_new/backend/profile.php (Flutter app)
```

**Kenapa salah?**
- Flutter app mengakses API via `ApiConfig.baseUrl` yang mengarah ke `http://192.168.1.7/jawara/pbl_new/backend/`
- Jika file PHP di root `backend/`, maka endpoint menjadi `http://192.168.1.7/jawara/backend/profile.php` → **404 Not Found**

**Sudah diperbaiki!** ✅
- File `profile.php` sudah dipindahkan ke `pbl_new/backend/profile.php`
- ProfileService sudah otomatis mengarah ke lokasi yang benar

---

## 🔧 Cara Kerja Endpoints

### Flutter App Config
File: `lib/config/api_config.dart`
```dart
class ApiConfig {
  static const String networkIp = '192.168.1.7';
  static String get baseUrl => 'http://$networkIp/jawara/pbl_new/backend';
  
  // Endpoints
  static String get productsEndpoint => '$baseUrl/products.php';
  static String get authEndpoint => '$baseUrl/auth.php';
  static String get chatEndpoint => '$baseUrl/chat.php';
  static String get categoriesEndpoint => '$baseUrl/categories.php';
  // ... dan seterusnya
}
```

### XAMPP htdocs Structure
```
C:\xampp\htdocs\jawara\
├── pbl_new/
│   └── backend/        ← PHP files untuk Flutter app
│       ├── config.php
│       ├── auth.php
│       ├── products.php
│       ├── profile.php  ← File yang diperbaiki
│       └── ...
└── backend/            ← Python/Docker untuk ML (tidak diakses Flutter)
    └── ml_api_docker.py
```

---

## 📝 Checklist untuk Developer

Sebelum membuat file backend baru, tanyakan:

### ❓ Untuk apa file ini?
- **Untuk Flutter app (PHP/MySQL)?** 
  → Taruh di `pbl_new/backend/`
  
- **Untuk ML/Python/Docker?** 
  → Taruh di `backend/` (root)

### ❓ File PHP apa yang perlu dibuat?
**Di `pbl_new/backend/` untuk:**
- User management
- Products/Categories
- Chat/Messages
- Transactions
- Notifications
- Profile
- Any CRUD operations

**Di `backend/` (root) untuk:**
- ML model deployment
- Docker configuration
- Python API scripts
- Tidak ada PHP untuk Flutter!

---

## 🚀 Quick Reference

| File Type | Lokasi | Contoh |
|-----------|--------|--------|
| PHP API untuk Flutter | `pbl_new/backend/` | `profile.php`, `auth.php` |
| SQL Migrations | `pbl_new/backend/migrations/` | `07_notifications.sql` |
| Python ML API | `backend/` | `ml_api_docker.py` |
| Docker Files | `backend/` | `Dockerfile`, `docker-compose.yml` |
| Flutter Services | `pbl_new/lib/core/services/` | `profile_service.dart` |
| Config | `pbl_new/lib/config/` | `api_config.dart` |

---

## 🔥 TL;DR

- 2 folder backend → **BERBEDA FUNGSI**
- `backend/` (root) = ML/Docker
- `pbl_new/backend/` = Flutter app (PHP)
- **Semua PHP untuk Flutter harus di `pbl_new/backend/`**
- Profile.php sudah diperbaiki ke lokasi yang benar ✅
