# Cara Menggunakan API Hugging Face untuk Deteksi Pakaian

## ❌ Yang Anda Lihat (Root Endpoint - Info Saja)
```bash
GET https://crushedkatana-clothing-clasification.hf.space/
```

Response:
```json
{
  "name": "PCVK Clothing Detection API",
  "version": "1.0.0-docker",
  "status": "ready",
  "model": "HOG + RBF SVM",
  "categories": ["Topi", "Kemeja", "Sepatu", "T-Shirt"],
  "endpoints": {
    "GET /": "API information",
    "GET /health": "Health check",
    "POST /detect": "Detect clothing category"
  }
}
```

Ini **BUKAN ERROR**, hanya informasi API.

---

## ✅ Cara Benar: Endpoint `/detect`

### 1. **Test dengan cURL (Command Line)**

```bash
curl -X POST https://crushedkatana-clothing-clasification.hf.space/detect \
  -F "data=@path/to/gambar_baju.jpg"
```

**Contoh:**
```bash
# Windows CMD
curl -X POST https://crushedkatana-clothing-clasification.hf.space/detect -F "data=@C:\Users\chare\Pictures\kemeja.jpg"

# Linux/Mac
curl -X POST https://crushedkatana-clothing-clasification.hf.space/detect -F "data=@/home/user/kemeja.jpg"
```

### 2. **Test dengan Postman**

1. Method: **POST**
2. URL: `https://crushedkatana-clothing-clasification.hf.space/detect`
3. Body → **form-data**
4. Key: `data` (pilih **File**)
5. Value: Upload file gambar (jpg/png)
6. Click **Send**

### 3. **Response yang Diharapkan**

```json
{
  "success": true,
  "predicted_class": "Kemeja",
  "confidence": 0.92,
  "top3_predictions": [
    {
      "class": "Kemeja",
      "confidence": 0.92
    },
    {
      "class": "T-Shirt",
      "confidence": 0.05
    },
    {
      "class": "Topi",
      "confidence": 0.02
    }
  ],
  "method": "HOG + SVM (Docker)",
  "timestamp": "2025-12-18T10:30:15"
}
```

---

## 🔧 Implementasi di Flutter

File `clothing_detection_service.dart` sudah benar menggunakan field `data`:

```dart
// Correct implementation (sudah ada di file)
var request = http.MultipartRequest('POST', Uri.parse(_detectEndpoint));

// Add image file with field name 'data'
request.files.add(
  await http.MultipartFile.fromPath('data', imagePath)
);

var streamedResponse = await request.send();
```

**Endpoint yang digunakan:**
```dart
// lib/config/api_config.dart
static const String mlDetectionEndpoint = 
  'https://crushedkatana-clothing-clasification.hf.space/detect';
```

---

## 🚨 Troubleshooting

### Error 1: "No image file provided (field: data)"
**Penyebab:** Field name salah (pakai `image` atau `file` bukan `data`)

**Fix:** Pastikan field name = `data`
```dart
// ❌ WRONG
request.files.add(await http.MultipartFile.fromPath('image', imagePath));

// ✅ CORRECT
request.files.add(await http.MultipartFile.fromPath('data', imagePath));
```

### Error 2: Timeout / 503 Service Unavailable
**Penyebab:** HF Space sleeping (cold start) atau error

**Fix:** 
- Wait 1-2 menit untuk cold start
- Cek status: https://huggingface.co/spaces/CrushedKatana/clothing_clasification
- Service sudah ada retry logic otomatis (2x dengan backoff)

### Error 3: "Package 'libgl1-mesa-glx' has no installation candidate"
**Penyebab:** Dockerfile masih pakai package lama

**Fix:** Edit Dockerfile di HF Space (ganti `libgl1-mesa-glx` → `libgl1`)

---

## 📱 Cara Pakai di App Flutter

### 1. Ambil Gambar
```dart
final picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);
```

### 2. Panggil Service
```dart
import 'package:pbl_new/core/services/clothing_detection_service.dart';

// Deteksi gambar
final result = await ClothingDetectionService.detectClothing(
  image.path,  // Path gambar lokal
  userId,      // ID user
);

// Cek hasil
if (result['success'] == true) {
  String category = result['predicted_class'];  // "Kemeja"
  double confidence = result['confidence'];     // 0.92
  
  print('Kategori: $category');
  print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
} else {
  print('Error: ${result['message']}');
}
```

### 3. Handle Loading & Error
```dart
bool _isDetecting = false;
String? _errorMessage;

Future<void> _detectImage() async {
  setState(() {
    _isDetecting = true;
    _errorMessage = null;
  });

  try {
    final result = await ClothingDetectionService.detectClothing(
      _imagePath!,
      _userId,
    );

    if (result['success'] == true) {
      // Success - show result
      _showResultDialog(result['predicted_class']);
    } else {
      // Error from API
      setState(() {
        _errorMessage = result['message'];
      });
    }
  } catch (e) {
    // Network error
    setState(() {
      _errorMessage = 'Gagal koneksi ke server: $e';
    });
  } finally {
    setState(() {
      _isDetecting = false;
    });
  }
}
```

---

## 🧪 Test Manual Cepat

### 1. Health Check
```bash
curl https://crushedkatana-clothing-clasification.hf.space/health
```

Expected:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2025-12-18T10:30:00"
}
```

### 2. API Info
```bash
curl https://crushedkatana-clothing-clasification.hf.space/
```

Expected: JSON dengan info API (yang Anda lihat sekarang)

### 3. Detection (dengan sample image)
```bash
# Download sample image dulu
curl -o test_shirt.jpg https://example.com/shirt.jpg

# Test detection
curl -X POST https://crushedkatana-clothing-clasification.hf.space/detect \
  -F "data=@test_shirt.jpg"
```

---

## 📊 Format Response Detail

```json
{
  "success": true,
  "predicted_class": "Kemeja",           // Kategori utama
  "confidence": 0.92,                    // Confidence 0-1
  "top3_predictions": [                  // Top 3 prediksi
    {
      "class": "Kemeja",
      "confidence": 0.92
    },
    {
      "class": "T-Shirt",
      "confidence": 0.05
    },
    {
      "class": "Topi",
      "confidence": 0.02
    }
  ],
  "method": "HOG + SVM (Docker)",        // Model info
  "timestamp": "2025-12-18T10:30:15"     // Waktu prediksi
}
```

---

## 🎯 Next Steps

1. **Test endpoint manual** dengan curl/Postman dulu
2. Pastikan dapat response `predicted_class`
3. Jika berhasil, test dari Flutter app
4. Monitor logs di HF Space jika ada error

**HF Space URL:**
- App: https://huggingface.co/spaces/CrushedKatana/clothing_clasification
- Logs: https://huggingface.co/spaces/CrushedKatana/clothing_clasification?logs=container
