# Panduan Fitur Machine Learning PCVK

## Deskripsi
Fitur deteksi pakaian menggunakan metode HOG (Histogram of Oriented Gradients) + SVM (Support Vector Machine) untuk mengklasifikasikan kategori pakaian.

## Teknologi yang Digunakan

### Backend
- **PHP**: Endpoint ML detection dan history
- **Python 3.14**: Training dan inference model
- **MySQL**: Penyimpanan hasil deteksi

### Machine Learning
- **Metode**: HOG + SVM
- **Library**: scikit-learn, scikit-image, opencv-python
- **Model Output**: `clothing_svm_best.pkl`, `clothing_scaler_best.pkl`

### Frontend (Flutter)
- **Services**: `ClothingDetectionService`
- **Screens Warga**: 
  - `ClothingDetectionScreen` - Deteksi pakaian
  - `ClothingDetectionHistoryScreen` - Riwayat deteksi
- **Screens Admin**: 
  - `MLStatisticsScreen` - Dashboard statistik ML
- **Dependencies**: `image_picker`, `http`, `fl_chart`

## Alur Penggunaan

### Untuk User Warga

1. **Navigasi ke Deteksi Pakaian**
   ```dart
   Navigator.pushNamed(
     context,
     '/clothing_detection',
     arguments: userId,
   );
   ```

2. **Ambil/Pilih Gambar**
   - Pilih dari galeri atau
   - Ambil foto dari kamera

3. **Proses Deteksi**
   - Klik tombol "Deteksi Pakaian"
   - Sistem akan mengirim gambar ke backend PHP
   - Backend memanggil Python script untuk inference
   - Hasil deteksi ditampilkan dengan:
     - Kategori pakaian (predicted_class)
     - Confidence score
     - Top-3 prediksi alternatif

4. **Lihat Riwayat**
   - Klik icon history di AppBar
   - Tampilkan statistik personal dan riwayat deteksi

### Untuk Admin

1. **Navigasi ke Dashboard ML**
   ```dart
   Navigator.pushNamed(context, '/ml_statistics');
   ```

2. **Lihat Statistik Global**
   - Total deteksi
   - Total user yang menggunakan
   - Average confidence
   - Kategori terbanyak
   - Grafik deteksi per kategori
   - Deteksi terbaru

## Backend Endpoints

### 1. ML Detection
**Endpoint**: `POST /backend/ml_detection.php`

**Request**:
- `image`: File gambar (multipart/form-data)
- `user_id`: ID user

**Response**:
```json
{
  "success": true,
  "predicted_class": "Kemeja",
  "confidence": 0.92,
  "top3_predictions": [
    {"class": "Kemeja", "confidence": 0.92},
    {"class": "Blouse", "confidence": 0.05},
    {"class": "Jaket", "confidence": 0.02}
  ],
  "execution_time": 1.234
}
```

### 2. Get History
**Endpoint**: `POST /backend/ml_detection_history.php`

**Request**:
- `action`: "get_history"
- `user_id`: ID user
- `limit`: Jumlah record (default: 20)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 123,
      "predicted_class": "Kemeja",
      "confidence": 0.92,
      "created_at": "2025-12-03 14:30:00"
    }
  ]
}
```

### 3. Get Statistics
**Endpoint**: `POST /backend/ml_detection_history.php`

**Request**:
- `action`: "get_stats"
- `user_id`: ID user

**Response**:
```json
{
  "success": true,
  "stats": {
    "total_detections": 45,
    "by_category": [
      {"category": "Kemeja", "count": 15},
      {"category": "Celana", "count": 12}
    ]
  }
}
```

### 4. Save Detection
**Endpoint**: `POST /backend/ml_detection_history.php`

**Request**:
- `action`: "save"
- `user_id`: ID user
- `image_path`: Path file gambar
- `predicted_class`: Kategori hasil prediksi
- `confidence`: Score confidence
- `top3_predictions`: JSON top-3 predictions

## Database Schema

```sql
CREATE TABLE ml_detections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    image_path VARCHAR(255),
    predicted_class VARCHAR(100) NOT NULL,
    confidence DECIMAL(5,4),
    top3_predictions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Troubleshooting

### Error: "No module named 'seaborn'"
**Solusi**: Install dependencies
```bash
cd d:\CloneGithub\New_PBL_Jawara\ml_training
py -3.14 -m pip install -r requirements.txt
```

### Error: "Model file not found"
**Solusi**: Train model terlebih dahulu
```bash
cd d:\CloneGithub\New_PBL_Jawara\ml_training\scripts
py -3.14 train_model.py
```

### Error: "Connection refused"
**Solusi**: Pastikan XAMPP Apache dan MySQL running
- Buka XAMPP Control Panel
- Start Apache dan MySQL
- Cek endpoint di `http://localhost/pbl_jawara/backend/`

### Error: "Image picker not working"
**Solusi**: Tambahkan permission di AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Testing

### Test Manual dengan cURL
```bash
# Test detection endpoint
curl -X POST http://localhost/pbl_jawara/backend/ml_detection.php \
  -F "image=@test_image.jpg" \
  -F "user_id=1"

# Test history endpoint
curl -X POST http://localhost/pbl_jawara/backend/ml_detection_history.php \
  -d "action=get_history&user_id=1&limit=10"

# Test stats endpoint
curl -X POST http://localhost/pbl_jawara/backend/ml_detection_history.php \
  -d "action=get_stats&user_id=1"
```

### Test Python Script Langsung
```bash
cd d:\CloneGithub\New_PBL_Jawara\ml_training\scripts
py -3.14 predict.py --image path/to/test_image.jpg
```

## Best Practices

1. **Image Size**: Resize gambar ke max 1024x1024 sebelum upload untuk performa optimal
2. **Error Handling**: Selalu tangani error dari API dengan try-catch
3. **Loading State**: Tampilkan loading indicator saat proses deteksi
4. **Offline Mode**: Simpan hasil deteksi lokal jika backend tidak tersedia
5. **Cache**: Cache model predictions untuk gambar yang sama

## Referensi
- [HOG+SVM Guide](./HOG_SVM_GUIDE.md)
- [ML Implementation](./ML_IMPLEMENTATION.md)
- [Backend README](../backend/README.md)
