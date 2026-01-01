# LAPORAN PCVK DETEKSI PAKAIAN (BAHASA INDONESIA)

## 1. Gambaran Umum

Komponen PCVK (Pengolahan Citra dan Visi Komputer) pada **JAWARA CLOTHING STORE** mengimplementasikan fitur deteksi pakaian end‑to‑end yang secara otomatis mengklasifikasikan foto pakaian ke dalam empat kategori:

- Hat (Topi)
- Shirt (Kemeja)
- T‑Shirt (Kaos)
- Shoes (Sepatu)

Laporan ini fokus pada:
- Bahasa pemrograman dan teknologi yang digunakan
- Metode HOG + SVM dan alur data
- Library dan tools yang digunakan
- Integrasi antara Python (ML), PHP (backend), dan Flutter (mobile)
- Cuplikan kode penting dan contoh screenshot.

---

## 2. Bahasa & Teknologi

### 2.1 Lapisan Machine Learning (Training & Inference)

- **Bahasa**: Python 3.x
- **File Utama** (di folder `ml_training/`):
  - `ml_training/scripts/preprocess.py`
  - `ml_training/scripts/train_model.py`
  - `ml_training/scripts/predict.py`
  - `ml_training/models/clothing_svm_best.pkl`
  - `ml_training/models/clothing_scaler_best.pkl`
- **Library Inti**:
  - `numpy` – operasi numerik dan array
  - `scikit-image` – ekstraksi fitur HOG
  - `scikit-learn` – klasifier SVM, train/test split, evaluasi metrik
  - `joblib` – menyimpan dan memuat model `.pkl`
  - `pillow` atau `opencv-python` – load dan resize gambar (tergantung environment)

### 2.2 Lapisan Integrasi Backend

- **Bahasa**: PHP 8.x
- **Lokasi File**: `pbl_new/backend/ml_detection.php`
- **Tanggung Jawab**:
  - Menerima upload gambar dari aplikasi Flutter
  - Memanggil script Python `predict.py` melalui CLI
  - Membaca output JSON dari Python dan mengembalikannya sebagai respons JSON API
  - Opsional: mencatat hasil deteksi ke tabel MySQL `ml_detections` (lihat `05_ml_detections.sql`).

### 2.3 Lapisan Client Mobile (Flutter)

- **Bahasa**: Dart (Flutter)
- **File Kunci**:
  - `pbl_new/lib/core/services/clothing_detection_service.dart`
  - `pbl_new/lib/features/warga/screens/camera_detection_screen.dart`
  - `pbl_new/lib/features/warga/screens/add_product_screen.dart`
- **Paket Inti**:
  - `http` – memanggil endpoint ML di backend
  - `image_picker` / `camera` – mengambil foto dari kamera atau gallery
  - State management Flutter (Provider/BLoC) – menghubungkan hasil deteksi ke UI

---

## 3. Metode: HOG + SVM

### 3.1 HOG (Histogram of Oriented Gradients)

- Gambar input di‑resize ke ukuran **128×128** piksel.
- Gambar diubah menjadi grayscale dan dinormalisasi.
- Parameter HOG (lihat `ml_training/scripts/preprocess.py` dan panduan PCVK):
  - `orientations = 9` (jumlah arah gradien)
  - `pixels_per_cell = (8, 8)`
  - `cells_per_block = (2, 2)`
  - `transform_sqrt = True`
- Output: satu vektor fitur HOG per gambar dengan dimensi sekitar **8.100 fitur**.

### 3.2 Klasifier SVM

- Algoritma: **Support Vector Machine (SVM)** dengan kernel RBF.
- Parameter utama (lihat `ml_training/scripts/train_model.py`):
  - `kernel='rbf'`
  - `C=10.0`
  - `gamma='scale'`
  - `decision_function_shape='ovr'` (One‑vs‑Rest untuk multi‑kelas)
  - `probability=True` (menghasilkan skor probabilitas / confidence)
- Dataset:
  - Sumber: Kaggle Clothing Dataset
  - 4 kelas: Hat, Shirt, T‑Shirt, Shoes
  - 1.991 gambar asli → sekitar 3.982 sampel setelah augmentasi
  - Pembagian: 60% train, 20% validation, 20% test
- Performa (model PCVK baseline):
  - Akurasi ≈ 88%
  - Waktu inferensi ≈ 50–100 ms per gambar (CPU)

---

## 4. Arsitektur & Alur Data

### 4.1 Alur Tingkat Tinggi

```text
Flutter App (User Warga)
  └─ "Jual Pakaian" → "Tambah Produk" → [Tombol PCVK]
        ↓
Ambil foto / pilih gambar (camera_detection_screen.dart)
        ↓
Kirim file gambar via HTTP multipart ke PHP backend
        ↓
PHP (ml_detection.php) memanggil Python predict.py
        ↓
Python load model HOG+SVM, ekstrak fitur, prediksi kelas
        ↓
Python mengeluarkan JSON → PHP meneruskan JSON ke Flutter
        ↓
Flutter menampilkan kategori + confidence,
melakukan autofill field kategori produk, dan dapat menyimpan riwayat.
```

### 4.2 Komponen Utama

- **Python**: berisi logika ML (ekstraksi fitur + klasifikasi).
- **PHP**: lapisan penghubung antara HTTP dan Python; juga bisa menulis log ke tabel `ml_detections`.
- **Flutter**: UI yang digunakan user untuk memicu deteksi, melihat hasil, dan menyimpan riwayat.

---

## 5. Contoh Cuplikan Kode

> Catatan: Nama fungsi dan struktur kodenya sama seperti di versi Bahasa Inggris; komentar di bawah menjelaskan peran tiap lapisan.

### 5.1 Python – Ekstraksi Fitur HOG & Prediksi SVM

**File**: `ml_training/scripts/predict.py` (versi disederhanakan)

```python
from skimage.feature import hog
from skimage.io import imread
from skimage.transform import resize
import joblib
import json
import sys

# Load model & scaler
model = joblib.load('../models/clothing_svm_best.pkl')
scaler = joblib.load('../models/clothing_scaler_best.pkl')

IMAGE_SIZE = (128, 128)

def extract_hog_features(image_path):
    img = imread(image_path, as_gray=True)
    img_resized = resize(img, IMAGE_SIZE)
    features = hog(
        img_resized,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        transform_sqrt=True,
    )
    return features

if __name__ == "__main__":
    image_path = sys.argv[1]
    feats = extract_hog_features(image_path).reshape(1, -1)
    feats_scaled = scaler.transform(feats)

    probs = model.predict_proba(feats_scaled)[0]
    classes = model.classes_
    top_idx = probs.argmax()

    result = {
        "success": True,
        "predicted_class": str(classes[top_idx]),
        "confidence": float(probs[top_idx]),
    }

    print(json.dumps(result))
```

Script ini dipanggil oleh PHP dan mencetak **satu baris JSON** yang kemudian diteruskan ke aplikasi mobile.

### 5.2 PHP – Endpoint Backend

**File**: `pbl_new/backend/ml_detection.php`

```php
function detectClothing($imagePath) {
    $pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
    $modelPath   = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
    $scalerPath  = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';
    $pythonExe   = 'C:\\Users\\chare\\AppData\\Local\\Python\\bin\\python.exe';

    $command = sprintf(
        '"%s" "%s" --image "%s" --model "%s" --scaler "%s" 2>&1',
        $pythonExe,
        $pythonScript,
        $imagePath,
        $modelPath,
        $scalerPath
    );

    exec($command, $output, $returnCode);
    $outputStr = implode("\n", $output);

    if ($returnCode !== 0) {
        return [
            'success' => false,
            'message' => 'Python execution failed',
            'debug'   => $outputStr,
        ];
    }

    $result = json_decode($outputStr, true);
    return $result ?: [
        'success' => false,
        'message' => 'Invalid JSON from ML script',
        'raw_output' => $outputStr,
    ];
}
```

Implementasi asli di repo juga menambahkan penanganan error yang lebih lengkap dan pencatatan ke database (lihat `pbl_new/backend/ml_detection.php`).

### 5.3 Dart/Flutter – Client API ML

**File**: `pbl_new/lib/core/services/clothing_detection_service.dart`

```dart
class ClothingDetectionService {
  static String get _detectEndpoint => ApiConfig.mlDetectionEndpoint;

  static Future<Map<String, dynamic>> detectClothing(
    String imagePath,
    int userId, {
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Map<String, dynamic>? lastError;

    while (attempt <= maxRetries) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }

        final request = http.MultipartRequest('POST', Uri.parse(_detectEndpoint));
        request.files.add(
          await http.MultipartFile.fromPath('data', imagePath),
        );

        final streamed = await request.send().timeout(
          const Duration(seconds: 90),
        );
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final fullResult = json.decode(response.body);

          // Format respons ML langsung
          if (fullResult is Map && fullResult.containsKey('predicted_class')) {
            fullResult['user_id'] = userId;
            return Map<String, dynamic>.from(fullResult);
          }

          return {
            'success': false,
            'message': 'Unexpected response format',
            'raw_response': fullResult,
          };
        }

        return {
          'success': false,
          'message': 'API Error ${response.statusCode}',
        };
      } catch (e) {
        lastError = {
          'success': false,
          'message': 'Exception while calling ML API',
          'detail': e.toString(),
        };
        attempt++;
      }
    }

    return lastError ?? {
      'success': false,
      'message': 'Failed to contact ML server',
    };
  }
}
```

Kelas service ini dipanggil dari layar "Tambah Produk" dan "Camera Detection" untuk mengirim gambar ke backend dan mengisi hasil deteksi ke form.

---

## 6. Screenshot (Disarankan)

Untuk versi PDF akhir, Anda dapat menyertakan screenshot berikut (ambil dari aplikasi yang sudah berjalan dan/atau dari database/backend):

1. **Mobile – Halaman Tambah Produk dengan Tombol PCVK**  
   `![Tambah Produk dengan Tombol PCVK](../assets/screenshots/pcvk_add_product_button.png)`

2. **Mobile – Layar Kamera Deteksi**  
   `![Layar Kamera Deteksi](../assets/screenshots/pcvk_camera_detection.png)`

3. **Mobile – Hasil Deteksi Muncul di Form**  
   `![Hasil Deteksi Autofill](../assets/screenshots/pcvk_detection_result.png)`

4. **Backend – Tabel ml_detections di phpMyAdmin**  
   `![Tabel ML Detections](../assets/screenshots/pcvk_ml_detections_table.png)`

5. **Admin Dashboard – Statistik PCVK**  
   `![Dashboard Admin PCVK](../assets/screenshots/pcvk_admin_dashboard.png)`

---

## 7. Ringkasan

- PCVK menggunakan model **Python HOG + SVM** untuk klasifikasi pakaian, dilatih pada ~4.000 gambar dan disimpan sebagai file `.pkl`.
- **Backend PHP** membungkus script Python dan menyediakan REST API JSON yang rapi untuk diakses aplikasi mobile.
- Aplikasi mobile **Flutter** mengintegrasikan PCVK melalui `ClothingDetectionService`, mengirim gambar dan menampilkan prediksi di alur "Jual Pakaian".
- Fitur ini didesain agar **cepat, cukup mudah dijelaskan, dan bisa dideploy** pada infrastruktur CPU‑only yang umum.

Laporan ini dapat dijadikan **bab utama PCVK** di dokumen/slide/PDF akhir untuk menjelaskan implementasi sistem deteksi pakaian dari ujung ke ujung.
