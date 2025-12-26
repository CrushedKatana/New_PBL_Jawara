# PBL Jawara - Smart Marketplace RT/RW

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?logo=php)](https://php.net)
[![Python](https://img.shields.io/badge/Python-3.10-3776AB?logo=python)](https://python.org)

Aplikasi marketplace berbasis komunitas RT/RW dengan fitur AI untuk deteksi produk pakaian dan sistem manajemen warga terintegrasi.

## 📋 Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur Utama](#fitur-utama)
- [Teknologi](#teknologi)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Struktur Proyek](#struktur-proyek)
- [Instalasi](#instalasi)
- [Panduan Penggunaan](#panduan-penggunaan)
- [Machine Learning](#machine-learning)
- [API Documentation](#api-documentation)
- [Tim Pengembang](#tim-pengembang)

---

## 🎯 Tentang Proyek

**PBL Jawara** adalah aplikasi mobile marketplace yang dirancang khusus untuk komunitas RT/RW, memungkinkan warga untuk:
- Berjualan dan membeli produk dalam lingkungan RT/RW
- Berkomunikasi melalui sistem chat terintegrasi
- Menggunakan AI untuk mendeteksi kategori produk pakaian secara otomatis
- Sistem manajemen RT dengan dashboard monitoring real-time
- Panel admin untuk kontrol penuh sistem

### Problem Statement
- Warga kesulitan menjual/membeli produk dalam komunitas
- Tidak ada platform khusus untuk transaksi lokal RT/RW
- Proses kategorisasi produk manual memakan waktu
- RT kesulitan monitoring aktivitas dan statistik warga

### Solution
Aplikasi mobile dengan 3 role user (Warga, RT, Admin) yang terintegrasi dengan AI untuk deteksi otomatis produk pakaian menggunakan Computer Vision.

---

## ✨ Fitur Utama

### 👤 Role Warga
- **Marketplace**: Jual-beli produk dengan gambar, harga, kategori
- **AI Detection**: Upload foto pakaian → otomatis terdeteksi (Kaos, Kemeja, Topi, Sepatu)
- **Chat**: Komunikasi real-time dengan penjual/pembeli
- **Profil**: Kelola data pribadi, RT, dan riwayat transaksi

### 🏘️ Role RT
- **Dashboard RT**: Statistik warga, produk, transaksi per RT
- **Manajemen Warga**: Lihat daftar warga, approve/reject pendaftaran
- **Monitoring Aktivitas**: Log aktivitas real-time (transaksi, chat, login)
- **Laporan**: Export data bulanan/tahunan

### 👨‍💼 Role Admin
- **Dashboard Global**: Overview seluruh sistem (users, products, GMV)
- **User Management**: Filter by role (Warga/RT/Admin), edit, delete
- **ML Statistics**: Grafik deteksi per kategori, akurasi model, usage trends
- **System Health**: Monitor endpoint status (Auth, Products, Chat, ML API)
- **RT Performance**: Tabel leaderboard RT berdasarkan aktivitas

---

## 🛠️ Teknologi

### Mobile App (Flutter/Dart)
```
Flutter SDK: 3.9.2
Dart SDK: 3.9.2
```

**Dependencies:**
- `http` - REST API calls
- `provider` - State management
- `shared_preferences` - Local storage
- `image_picker` - Upload foto produk
- `camera` - Akses kamera untuk deteksi AI
- `intl` - Format tanggal/currency
- `fl_chart` - Grafik statistik

### Backend (PHP + MySQL)
```
PHP: 8.x
MySQL: 8.0
XAMPP/Laragon untuk development
```

**Endpoints:**
- `auth.php` - Login, register, session
- `products.php` - CRUD products, categories
- `chat.php` - Real-time messaging
- `users.php` - User management
- `rt_metrics.php` - RT statistics
- `ml_detections.php` - ML detection history

### Machine Learning (Python)
```
Python: 3.10
Framework: Flask/FastAPI
Model: HOG + SVM (scikit-learn)
Deployment: Hugging Face Spaces (Docker)
```

**Tech Stack:**
- **scikit-learn**: HOG feature extraction + SVM classifier
- **OpenCV**: Image preprocessing
- **scikit-image**: HOG descriptor
- **Flask/FastAPI**: REST API server
- **Docker**: Containerization untuk deployment
- **Hugging Face Spaces**: Cloud hosting gratis

**Model Performance:**
- Dataset: 4 kategori (Kaos, Kemeja, Topi, Sepatu)
- Accuracy: ~85-90%
- Inference Time: 1-3 detik
- Model Size: 145MB (tracked with Git LFS)

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────┐
│  Flutter App    │ (Mobile - Android/iOS)
│  (Warga/RT/Admin)│
└────────┬────────┘
         │ HTTP REST
         ├──────────────────┬──────────────────┐
         │                  │                  │
┌────────▼────────┐ ┌───────▼────────┐ ┌──────▼──────┐
│  PHP Backend    │ │   ML API       │ │ Firebase    │
│  (XAMPP/MySQL)  │ │ (HF Spaces)    │ │ (Optional)  │
└─────────────────┘ └────────────────┘ └─────────────┘
```

### Flow Deteksi ML
```
User Upload Image → Flutter App → ML API (HF Space) 
                                        ↓
                              HOG Feature Extraction
                                        ↓
                                  SVM Classifier
                                        ↓
                          Return: {category, confidence}
                                        ↓
                    Flutter App → Save to PHP Backend
```

---

## 📁 Struktur Proyek

```
New_PBL_Jawara/
│
├── pbl_new/                          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart                 # Entry point
│   │   ├── config/
│   │   │   └── api_config.dart       # API endpoints configuration
│   │   ├── core/
│   │   │   ├── models/               # Data models
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── notification_model.dart
│   │   │   │   └── ...
│   │   │   └── services/             # API services
│   │   │       ├── auth_service.dart
│   │   │       ├── product_service.dart
│   │   │       ├── clothing_detection_service.dart
│   │   │       ├── admin_service.dart
│   │   │       └── rt_service.dart
│   │   └── features/
│   │       ├── auth/                 # Login, Register, Splash
│   │       ├── warga/                # Beranda, Marketplace, Chat, Profil
│   │       ├── rt/                   # RT Dashboard, Warga List, RT Profil
│   │       └── admin/                # Admin Dashboard, User Mgmt, ML Stats
│   ├── backend/                      # PHP REST API
│   │   ├── config.php                # Database config
│   │   ├── auth.php
│   │   ├── products.php
│   │   ├── chat.php
│   │   ├── users.php
│   │   ├── categories.php
│   │   ├── rt_metrics.php
│   │   ├── ml_detections.php
│   │   └── migrations/               # SQL schema
│   ├── android/                      # Android config
│   ├── ios/                          # iOS config
│   └── pubspec.yaml                  # Flutter dependencies
│
├── huggingface_deployment/           # ML API Deployment
│   ├── clothing-detection/
│   │   ├── ml_api_docker.py          # Flask API untuk HF Spaces
│   │   ├── Dockerfile                # Docker container config
│   │   ├── requirements_docker.txt   # Python dependencies
│   │   ├── clothing_svm_best.pkl     # Trained model (145MB)
│   │   ├── clothing_scaler_best.pkl  # Feature scaler
│   │   └── README_HF_SPACE.md        # HF Space documentation
│   ├── HUGGINGFACE_TROUBLESHOOTING.md
│   ├── CARA_DEPLOY_KE_HUGGINGFACE.md
│   └── DEPLOY_DOCKER_KE_HF.md
│
├── ml_training/                      # ML Training Scripts
│   ├── train_model.py                # Training HOG+SVM
│   ├── dataset/                      # Raw images (gitignored)
│   └── models/                       # Trained models
│
├── Readme/                           # Documentation
│   ├── SETUP_GUIDE.md                # Instalasi lengkap
│   ├── AUTH_FLOW.md                  # Alur autentikasi
│   ├── CAMERA_AI_FEATURE.md          # Panduan AI detection
│   ├── ADMIN_DASHBOARD.md            # Panduan admin
│   └── USER_GUIDE.md                 # Panduan user
│
└── README.md                         # File ini
```

---

## 🚀 Instalasi

### Prerequisites
- **Flutter SDK** 3.9.2+ ([Download](https://flutter.dev/docs/get-started/install))
- **Android Studio** / **Xcode** (untuk emulator)
- **XAMPP** / **Laragon** (PHP + MySQL)
- **Git** (untuk clone repo)
- **Python 3.10+** (opsional, jika ingin training ulang model)

### Langkah 1: Clone Repository
```bash
git clone https://github.com/CrushedKatana/New_PBL_Jawara.git
cd New_PBL_Jawara
```

### Langkah 2: Setup Backend (PHP + MySQL)

1. **Start XAMPP/Laragon**
   ```bash
   # Windows: Jalankan XAMPP Control Panel
   # Start Apache dan MySQL
   ```

2. **Import Database**
   ```bash
   # Buka phpMyAdmin: http://localhost/phpmyadmin
   # Create database: marketplace_db
   # Import file: pbl_new/backend/migrations/*.sql
   ```

3. **Configure Database**
   Edit `pbl_new/backend/config.php`:
   ```php
   $host = 'localhost';
   $username = 'root';
   $password = '';  // Kosongkan jika default XAMPP
   $database = 'marketplace_db';
   ```

4. **Copy Backend ke htdocs**
   ```bash
   # Windows XAMPP
   copy pbl_new\backend C:\xampp\htdocs\marketplace_api
   
   # Test: http://localhost/marketplace_api/auth.php
   ```

### Langkah 3: Setup Flutter App

1. **Install Dependencies**
   ```bash
   cd pbl_new
   flutter pub get
   ```

2. **Configure API Endpoint**
   Edit `lib/config/api_config.dart`:
   ```dart
   // Untuk emulator Android
   static const String baseUrl = 'http://10.0.2.2/marketplace_api';
   
   // Untuk device fisik (ganti dengan IP komputer)
   // static const String baseUrl = 'http://192.168.1.100/marketplace_api';
   ```

3. **Run App**
   ```bash
   # List devices
   flutter devices
   
   # Launch emulator (jika belum running)
   flutter emulators --launch <emulator_id>
   
   # Run app
   flutter run
   ```

### Langkah 4: Setup ML API (Opsional - Sudah Deploy di HF)

ML API sudah di-deploy ke Hugging Face Spaces:
```
https://crushedkatana-clothing-clasification.hf.space/detect
```

Jika ingin deploy sendiri, ikuti:
- [CARA_DEPLOY_KE_HUGGINGFACE.md](huggingface_deployment/CARA_DEPLOY_KE_HUGGINGFACE.md)
- [DEPLOY_DOCKER_KE_HF.md](huggingface_deployment/DEPLOY_DOCKER_KE_HF.md)

---

## 📖 Panduan Penggunaan

### Login Credentials (Testing)
```
Admin:
Email: admin@jawara.com
Password: admin123

RT:
Email: rt01@jawara.com
Password: rt123

Warga:
Email: warga@jawara.com
Password: warga123
```

### Flow Penggunaan

#### 🧑 Sebagai Warga:
1. **Register** → Pilih RT → Tunggu approval RT
2. **Login** → Masuk ke Beranda
3. **Jual Produk**:
   - Klik tombol "+" di Jualan
   - Upload foto → AI auto-detect kategori
   - Isi nama, harga, deskripsi → Post
4. **Beli Produk**:
   - Browse di Beranda
   - Klik produk → Chat dengan penjual
5. **Chat**: Real-time messaging dengan user lain

#### 🏘️ Sebagai RT:
1. **Login** → Dashboard RT
2. **Approve Warga**: Menu "Daftar Warga" → Approve/Reject
3. **Monitor**: Lihat statistik produk, transaksi, aktivitas
4. **Laporan**: Export data bulanan untuk pelaporan

#### 👨‍💼 Sebagai Admin:
1. **Login** → Admin Dashboard
2. **User Management**: Filter by role, edit, delete users
3. **ML Statistics**: Monitor AI detection usage, akurasi
4. **System Health**: Cek status semua endpoints
5. **RT Performance**: Leaderboard RT terbaik

---

## 🤖 Machine Learning

### Model: HOG + SVM

**Histogram of Oriented Gradients (HOG) + Support Vector Machine (SVM)**

#### Kenapa HOG + SVM?
- **Lightweight**: Model size 145MB, inference < 3s
- **No GPU Required**: Bisa jalan di CPU (gratis di HF Spaces)
- **Proven Accuracy**: 85-90% untuk 4 kategori pakaian
- **Easy Deployment**: Scikit-learn → pickle → Flask API

#### Dataset
```
Total: ~2000+ images
├── Kaos: 500+ images
├── Kemeja: 500+ images
├── Topi: 500+ images
└── Sepatu: 500+ images
```

#### Training Pipeline
```python
1. Load images → Resize to 128x128
2. Convert to grayscale
3. Extract HOG features (orientations=9, pixels_per_cell=8x8)
4. Train SVM classifier (kernel='rbf', C=10, gamma=0.001)
5. Save model → .pkl files (Git LFS)
```

#### API Endpoint
```bash
POST https://crushedkatana-clothing-clasification.hf.space/detect
Content-Type: multipart/form-data

Body:
  image: <file.jpg>

Response:
{
  "category": "Kaos",
  "confidence": 0.92,
  "all_predictions": {
    "Kaos": 0.92,
    "Kemeja": 0.05,
    "Topi": 0.02,
    "Sepatu": 0.01
  }
}
```

#### Troubleshooting ML API
Jika ML API error 503/timeout, lihat:
- [HUGGINGFACE_TROUBLESHOOTING.md](huggingface_deployment/HUGGINGFACE_TROUBLESHOOTING.md)
- [CARA_CEK_DAN_FIX_HF_SPACE.md](huggingface_deployment/CARA_CEK_DAN_FIX_HF_SPACE.md)

**Retry Logic**: App otomatis retry 2x dengan exponential backoff (2-4 detik) jika API gagal.

---

## 📡 API Documentation

### Base URL
```
Development: http://localhost/marketplace_api
Production: https://your-domain.com/api
```

### Endpoints

#### Auth
```
POST /auth.php?action=register
Body: {name, email, password, rt, phone}

POST /auth.php?action=login
Body: {email, password}

GET /auth.php?action=check_session
Headers: {user_id, token}
```

#### Products
```
GET /products.php?action=get_all
GET /products.php?action=get_by_id&id=1
POST /products.php?action=create
Body: {name, category, price, image_base64, user_id}

PUT /products.php?action=update&id=1
DELETE /products.php?action=delete&id=1
```

#### Users (Admin)
```
GET /users.php?action=get_all&role=warga
GET /users.php?action=get_stats
PUT /users.php?action=update&id=1
DELETE /users.php?action=delete&id=1
```

#### RT Metrics
```
GET /rt_metrics.php?rt=1&month=12&year=2024
Response: {total_users, total_products, total_transactions, activities}
```

#### ML Detection History
```
POST /ml_detections.php?action=save
Body: {user_id, image_url, detected_category, confidence}

GET /ml_detections.php?action=get_stats
Response: {detection_by_category, total_detections, avg_confidence}
```

---

## 👥 Tim Pengembang

**PBL Jawara Team**

| Role | Tanggung Jawab |
|------|---------------|
| Mobile Developer | Flutter UI/UX, State Management, API Integration |
| Backend Developer | PHP REST API, MySQL Database, Authentication |
| ML Engineer | HOG+SVM Model Training, Flask API, HF Deployment |
| UI/UX Designer | Wireframe, Mockup, User Flow |
| Project Manager | Sprint Planning, Documentation, Testing |

---

## 📄 Lisensi

MIT License - Bebas digunakan untuk tujuan pendidikan dan komersial.

---

## 📞 Kontak & Support

- **GitHub Issues**: [Report Bug](https://github.com/CrushedKatana/New_PBL_Jawara/issues)
- **Email**: crushedkatana@example.com
- **Discord**: PBL Jawara Community

---

## 🎓 Dokumentasi Lengkap

Untuk panduan detail, lihat folder [Readme/](Readme/):
- [SETUP_GUIDE.md](Readme/SETUP_GUIDE.md) - Instalasi step-by-step
- [AUTH_FLOW.md](Readme/AUTH_FLOW.md) - Alur autentikasi & session
- [CAMERA_AI_FEATURE.md](Readme/CAMERA_AI_FEATURE.md) - Cara kerja AI detection
- [ADMIN_DASHBOARD.md](Readme/ADMIN_DASHBOARD.md) - Panduan admin lengkap
- [MARKETPLACE_README.md](Readme/MARKETPLACE_README.md) - Fitur marketplace
- [USER_GUIDE.md](Readme/USER_GUIDE.md) - Panduan user warga & RT

---

**⭐ Jika proyek ini membantu, jangan lupa star repo ini!**

```
Made with ❤️ by PBL Jawara Team
```
