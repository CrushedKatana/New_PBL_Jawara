# Machine Learning - Deteksi Pakaian PCVK

## 📁 Struktur Folder

Folder `ml_training` telah dibuat dengan struktur lengkap untuk training machine learning:

```
ml_training/
├── dataset/                          # Dataset untuk training
│   └── ml_ready_images_data.csv     # Dataset gambar pakaian
├── models/                          # Model ML yang sudah dilatih
│   ├── clothing_detector_best.h5    # Model terbaik (akan dibuat setelah training)
│   ├── clothing_detector_final.h5   # Model final
│   └── label_mapping.json           # Mapping kategori pakaian
├── scripts/                         # Script training dan prediksi
│   ├── preprocess.py               # Preprocessing data & augmentasi
│   ├── train_model.py              # Training model CNN
│   ├── evaluate.py                 # Evaluasi model
│   └── predict.py                  # Prediksi gambar (dipanggil dari PHP)
├── output/                          # Hasil training
│   ├── logs/                       # TensorBoard logs
│   ├── training_history.png        # Grafik accuracy & loss
│   └── confusion_matrix.png        # Confusion matrix
├── requirements.txt                 # Dependencies Python
└── README.md                       # Dokumentasi
```

## 🚀 Setup & Training

### 1. Install Dependencies

```bash
cd ml_training
pip install -r requirements.txt
```

### 2. Training Model

```bash
cd scripts
python train_model.py
```

Model yang tersedia:
- **MobileNetV2** (default, ringan & cepat)
- **EfficientNetB0** (akurasi tinggi)
- **Custom CNN** (dari scratch)

### 3. Evaluasi Model

```bash
python evaluate.py --model ../models/clothing_detector_best_YYYYMMDD_HHMMSS.h5
```

## 🔌 Integrasi dengan Aplikasi

### A. Backend (PHP)

**File yang dibuat:**

1. **`backend/ml_detection.php`**
   - Endpoint untuk deteksi pakaian
   - Upload gambar & call Python model
   - Return hasil prediksi

2. **`backend/ml_detection_history.php`**
   - Get riwayat deteksi user
   - Statistik per kategori
   - Global stats untuk admin

3. **`backend/migrations/05_ml_detections.sql`**
   - Tabel `ml_detections`
   - Sample data untuk testing

### B. Frontend (Flutter)

**File yang dibuat:**

1. **Service Layer:**
   - `lib/core/services/clothing_detection_service.dart`
   - Method: `detectClothing()`, `getDetectionHistory()`, `getCategoryStats()`

2. **Warga Screens:**
   - `lib/features/warga/screens/clothing_detection_screen.dart`
     - Upload foto dari galeri/kamera
     - Deteksi otomatis pakaian
     - Tampilkan hasil (kategori, confidence, top 3)
   
   - `lib/features/warga/screens/clothing_detection_history_screen.dart`
     - Riwayat deteksi user
     - Statistik per kategori

3. **Admin Dashboard:**
   - `lib/features/admin/screens/ml_statistics_screen.dart`
     - Total deteksi & user
     - Average confidence
     - Bar chart deteksi per kategori
     - List deteksi terbaru
     - Statistik per RT

## 📊 Fitur ML

### Untuk Warga:
✅ Upload foto pakaian dari galeri/kamera  
✅ Deteksi otomatis kategori pakaian  
✅ Confidence score & top 3 prediksi  
✅ Riwayat deteksi pribadi  
✅ Statistik kategori yang paling sering dideteksi

### Untuk Admin:
✅ Dashboard statistik ML global  
✅ Total deteksi & pengguna  
✅ Average confidence model  
✅ Chart deteksi per kategori  
✅ List deteksi terbaru dari semua user  
✅ Performa per RT  

## 🎯 Kategori Pakaian yang Didukung

Model dapat mendeteksi berbagai kategori pakaian seperti:
- Kemeja
- Celana / Celana Jeans / Celana Pendek
- Dress
- Jaket
- Rok
- Blouse
- Kaos
- Sweater
- Hoodie
- Dan lainnya (tergantung dataset)

## 🔧 Teknologi

**Machine Learning:**
- **HOG (Histogram of Oriented Gradients)** - Feature Extraction
   - Orientations: 9
   - Pixels per cell: 8x8  
   - Cells per block: 2x2
   - Transform sqrt: True
- **SVM (Support Vector Machine)** - Classification
   - Kernel: RBF (Radial Basis Function)
   - Hyperparameter: C=10.0, gamma='scale'
   - Multi-class: One-vs-Rest
- **Scikit-learn** untuk ML pipeline
- **Scikit-image** untuk HOG feature extraction
- **OpenCV** untuk image preprocessing
- Data Augmentation (rotation, flip, brightness)

**Backend:**
- PHP untuk API endpoints
- Python untuk ML inference
- MySQL untuk storage

**Frontend:**
- Flutter/Dart
- fl_chart untuk visualisasi
- image_picker untuk upload foto

## 📱 Cara Penggunaan

### Warga:
1. Buka menu "Deteksi Pakaian PCVK"
2. Pilih foto dari galeri atau ambil foto baru
3. Tap tombol "Deteksi Pakaian"
4. Lihat hasil deteksi & confidence score
5. Cek riwayat di menu History

### Admin:
1. Buka "Statistik Machine Learning"
2. Lihat overview cards (total deteksi, user, dll)
3. Analisis chart kategori terbanyak
4. Monitor deteksi terbaru
5. Refresh untuk update data

## 🗄️ Database Schema

```sql
CREATE TABLE ml_detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    predicted_class VARCHAR(100) NOT NULL,
    confidence DECIMAL(5, 4) NOT NULL,
    top3_predictions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES auth_users(id)
);
```

## 🚦 Next Steps

1. **Training Model:**
   - Jalankan `train_model.py` dengan dataset
   - Tunggu hingga training selesai
   - Model akan tersimpan di `models/`

2. **Testing Backend:**
   - Import migration `05_ml_detections.sql`
   - Test endpoint dengan Postman/cURL

3. **Testing Frontend:**
   - Build & run Flutter app
   - Test upload & deteksi
   - Verifikasi hasil di database

4. **Production:**
   - Fine-tune model parameters
   - Tambah dataset untuk improve accuracy
   - Setup production server untuk Python ML service

## 📝 Notes

- Model perlu dilatih terlebih dahulu sebelum bisa digunakan
- Pastikan Python environment sudah ter-install dengan benar
- Backend PHP perlu permission untuk execute Python command
- Gambar akan disimpan di `backend/uploads/ml_detections/`

---

**Status:** ✅ Complete - Siap untuk training dan testing!
