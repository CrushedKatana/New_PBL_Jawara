# Implementasi PCVK - Klasifikasi Pakaian Celana Sepatu Topi

## 📋 Ringkasan

Aplikasi PBL Jawara sekarang menggunakan **model Machine Learning HOG+SVM** yang telah ditraining untuk mengklasifikasikan 4 kategori PCVK:

1. **Hat** (Topi)
2. **Shirt** (Kemeja) 
3. **Shoes** (Sepatu)
4. **T-Shirt** (Kaos)

## 🎯 Teknologi

- **Model**: Support Vector Machine (SVM) dengan kernel RBF
- **Feature Extraction**: HOG (Histogram of Oriented Gradients)
- **Accuracy**: 88.22% validation accuracy
- **Dataset**: 3,982 samples (dengan augmentasi)
- **Python**: .conda/python.exe dengan scikit-learn

## 📱 Fitur Warga

### Klasifikasi PCVK via Kamera

**Lokasi Entry**: Beranda → Card "Klasifikasi PCVK"

**Flow Pengguna**:
1. User tap card "Klasifikasi PCVK" 
2. Pilih sumber gambar:
   - 📷 Kamera (ambil foto langsung)
   - 🖼️ Galeri (pilih dari foto)
3. Ambil/pilih foto item PCVK
4. Tap tombol "Klasifikasi PCVK"
5. Sistem proses dengan model HOG+SVM
6. Hasil ditampilkan:
   - Kategori utama (Hat/Shirt/Shoes/T-Shirt)
   - Confidence score (%)
   - Top 3 prediksi alternatif

**File**: `lib/features/warga/screens/clothing_detection_screen.dart`

### Backend Processing

**Endpoint**: `backend/ml_detection.php`

**Proses**:
```
Flutter App → Upload Image
     ↓
PHP Backend → Save ke uploads/ml_detections/
     ↓
Call Python: .conda/python.exe predict.py
     ↓
Python ML → Preprocess (grayscale, resize 128x128)
     ↓
Extract HOG features (8100 dimensions)
     ↓
Normalize with StandardScaler
     ↓
Predict with SVM model
     ↓
Return JSON result
     ↓
PHP → Save to database (ml_detections)
     ↓
Return to Flutter → Display results
```

## 👨‍💼 Fitur Admin

### Statistik PCVK Dashboard

**Lokasi**: Admin Dashboard → "Klasifikasi PCVK (ML)"

**Menampilkan**:
- 📊 Total klasifikasi yang dilakukan
- 👥 Jumlah user yang menggunakan fitur
- 📈 Average confidence score
- 🏆 Kategori paling banyak dideteksi
- 📉 Bar chart klasifikasi per kategori
- 🕒 Riwayat 10 klasifikasi terakhir

**File**: `lib/features/admin/screens/ml_statistics_screen.dart`

**API Endpoint**: `backend/ml_detection_history.php?action=get_global_stats`

## 🔧 Model Details

### HOG Features
- **Orientations**: 9
- **Pixels per cell**: 8x8
- **Cells per block**: 2x2
- **Transform sqrt**: True
- **Output dimension**: 8,100 features

### SVM Classifier
- **Kernel**: RBF (Radial Basis Function)
- **C**: 10.0
- **Gamma**: scale
- **Classes**: 4 (multiclass with One-vs-Rest)

### Preprocessing Pipeline
1. Load image dari kamera/galeri
2. Convert ke grayscale
3. Resize ke 128x128 pixels
4. Histogram equalization (kontras enhancement)
5. Extract HOG features
6. Normalize dengan StandardScaler
7. Predict dengan SVM
8. Return top prediction + confidence

## 📊 Database Schema

```sql
CREATE TABLE ml_detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    predicted_class VARCHAR(100) NOT NULL,  -- Hat, Shirt, Shoes, T-Shirt
    confidence DECIMAL(5, 4) NOT NULL,      -- 0.0000 - 1.0000
    top3_predictions TEXT,                   -- JSON array
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🚀 Testing Flow

### Test di Android/iOS Emulator

```bash
cd pbl_new
flutter run
```

### Test sebagai Warga:
1. Login dengan user warga (bukan admin)
2. Di Beranda, tap card "Klasifikasi PCVK"
3. Tap "Kamera" untuk ambil foto
4. Foto item pakaian/sepatu/topi
5. Tap "Klasifikasi PCVK"
6. Verifikasi hasil muncul dengan confidence score

### Test sebagai Admin:
1. Login sebagai admin
2. Buka Admin Dashboard
3. Scroll ke section "Klasifikasi PCVK (ML)"
4. Tap "Statistik Klasifikasi PCVK"
5. Verifikasi data statistik muncul:
   - Total detections
   - User count
   - Category breakdown chart
   - Recent detections list

## 📝 API Dokumentasi

### 1. Klasifikasi Image

**Endpoint**: `POST /backend/ml_detection.php`

**Request**:
```
Content-Type: multipart/form-data

Fields:
- image: <binary file> (JPG/PNG, max 10MB)
- user_id: <integer>
```

**Response Success**:
```json
{
  "success": true,
  "predicted_class": "T-Shirt",
  "confidence": 0.9925,
  "top3_predictions": [
    {"class": "T-Shirt", "confidence": 0.9925},
    {"class": "Shirt", "confidence": 0.0034},
    {"class": "Shoes", "confidence": 0.0023}
  ],
  "message": "Detection successful"
}
```

**Response Error**:
```json
{
  "success": false,
  "message": "Error message here"
}
```

### 2. Get History (User)

**Endpoint**: `POST /backend/ml_detection_history.php`

**Request**:
```
action: get_history
user_id: <integer>
limit: 20 (optional)
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "predicted_class": "Hat",
      "confidence": 0.9234,
      "top3_predictions": [...],
      "created_at": "2025-12-03 14:30:00"
    }
  ]
}
```

### 3. Get Global Stats (Admin)

**Endpoint**: `POST /backend/ml_detection_history.php`

**Request**:
```
action: get_global_stats
```

**Response**:
```json
{
  "success": true,
  "stats": {
    "total_detections": 1247,
    "total_users": 89,
    "avg_confidence": 0.8822,
    "most_detected_category": "T-Shirt",
    "by_category": [
      {"category": "T-Shirt", "count": 450},
      {"category": "Hat", "count": 342},
      {"category": "Shirt", "count": 255},
      {"category": "Shoes", "count": 200}
    ],
    "recent_detections": [...]
  }
}
```

## ✅ Checklist Implementasi

- [x] Model HOG+SVM ditraining (88.22% accuracy)
- [x] 4 kategori PCVK terdefinisi (Hat, Shirt, Shoes, T-Shirt)
- [x] Screen klasifikasi dengan kamera untuk warga
- [x] Backend PHP integration dengan Python ML
- [x] Database table ml_detections
- [x] Admin statistics dashboard
- [x] API endpoints (detect, history, stats)
- [x] UI/UX updated dengan terminologi PCVK
- [ ] Testing end-to-end flow
- [ ] Deploy ke production server

## 🎓 Perbedaan dengan AI Detection

| Aspek | AI Detection (Sebelumnya) | PCVK ML Model (Sekarang) |
|-------|---------------------------|--------------------------|
| Model | Generic AI | HOG + SVM (Trained) |
| Kategori | Tidak spesifik | 4 kategori PCVK fix |
| Akurasi | Tidak terukur | 88.22% validated |
| Processing | Cloud API | Local Python script |
| Speed | Tergantung network | Lokal, lebih cepat |
| Customization | Sulit | Mudah retrain |

## 🔐 Catatan Keamanan

1. ✅ Validasi tipe file (JPG/PNG only)
2. ✅ Limit ukuran file (max 10MB)
3. ✅ Unique filename generation
4. ✅ Database foreign key ke auth_users
5. ⚠️ TODO: Rate limiting API
6. ⚠️ TODO: JWT authentication
7. ⚠️ TODO: Admin role verification

## 📈 Improvement Ideas

1. **Tambah Kategori**: Jaket, Celana Jeans, Dress, dll
2. **Retrain Model**: Dengan lebih banyak data (target 5000+ per kategori)
3. **Model Ensemble**: Kombinasi SVM + Random Forest
4. **Real-time Camera**: Klasifikasi langsung tanpa save image
5. **Batch Processing**: Upload multiple images sekaligus
6. **Export Report**: PDF laporan statistik admin

---

**Last Updated**: December 3, 2025  
**Model Version**: clothing_svm_best.pkl  
**Categories**: Hat, Shirt, Shoes, T-Shirt  
**Accuracy**: 88.22% validation
