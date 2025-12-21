# Laporan Pengembangan Aplikasi Mobile & PCVK

---

## Nama Aplikasi
**PBL Jawara Marketplace RT/RW** — Aplikasi Marketplace Terpadu dengan Fitur PCVK (Pengolahan Citra Visi Komputer)

---

## Deskripsi Aplikasi
Aplikasi ini adalah marketplace terintegrasi yang menghubungkan penjual dan pembeli di komunitas RT/RW. Fitur utama mencakup katalog produk, sistem pesan real-time, dashboard admin, dan yang terpenting: **fitur Clothing Detection berbasis AI** menggunakan Pengolahan Citra Visi Komputer (PCVK) untuk otomatis mengkategorikan pakaian saat upload produk, meningkatkan efisiensi dan akurasi kategorisasi.

Teknologi yang digunakan:
- **Frontend Mobile**: Flutter (Dart)
- **Backend API**: PHP RESTful API
- **Machine Learning**: HOG + SVM (Histogram of Oriented Gradients + Support Vector Machine)
- **Cloud Deployment**: Hugging Face Spaces (Model), Firebase (Auth & Real-time Messaging)

---

## Anggota Tim

| No. | Nama | NIM | Peran | Tanggung Jawab |
|-----|------|-----|------|----------------|
| 1 | Charellino K S | 2341720205 | PL / Mobile Developer | Pengembangan aplikasi mobile Flutter, integrasi fitur, UI/UX |
| 2 | M. Atho'illah M | 2341720210 | PM / ML Engineer | Pelatihan model machine learning, evaluasi, optimisasi |
| 3 | Mikaila Kafka | 2341720223 | PCVK (Computer Vision) | Implementasi computer vision, pengolahan citra, deteksi clothing |

---

## Implementasi Fitur Mobile (Flutter)

### #09 Kamera
**Deskripsi**: Kemampuan untuk menggunakan plugin kamera di Flutter.

**Tujuan**: Memungkinkan pengguna mengambil foto langsung dari aplikasi untuk upload produk pakaian.

**Implementasi**:
- Plugin: `camera` dan `image_picker`
- Fitur:
  - Tangkap foto dari kamera perangkat
  - Pilih gambar dari galeri
  - Preview gambar sebelum upload
  - Kompresi otomatis untuk optimasi ukuran

**Lokasi kode**: `pbl_new/lib/features/warga/presentation/widgets/camera_widget.dart`

**Contoh penggunaan**:
```dart
final ImagePicker _picker = ImagePicker();

Future<void> _takePicture() async {
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  if (photo != null) {
    setState(() {
      _selectedImage = File(photo.path);
    });
  }
}
```

---

### #10 Dasar State Management
**Deskripsi**: Kemampuan mengelola state di Flutter.

**Tujuan**: Mengelola state aplikasi secara efisien untuk UI responsif dan sinkronisasi data antar halaman.

**Implementasi**:
- State Management: Provider + BLOC Pattern
- Fitur:
  - Mengelola state produk (daftar, detail, form input)
  - Mengelola state autentikasi pengguna
  - Mengelola state cart dan pesanan
  - Notifikasi perubahan state ke UI

**Lokasi kode**:
- Provider: `pbl_new/lib/providers/`
- BLOC: `pbl_new/lib/features/*/bloc/`

**Contoh**:
```dart
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  
  List<Product> get products => _products;
  
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
}
```

---

### #11 Pemrograman Asynchronous
**Deskripsi**: Kemampuan melakukan pemrograman asynchronous di Flutter.

**Tujuan**: Menangani operasi long-running (API call, file I/O) tanpa memblokir UI.

**Implementasi**:
- Fitur:
  - Async/await untuk HTTP request
  - Future handling untuk operasi database
  - Loading indicator selama request
  - Error handling dan retry logic
  - Timeout handling untuk API calls

**Lokasi kode**: `pbl_new/lib/services/api_service.dart`, `pbl_new/lib/services/firebase_service.dart`

**Contoh**:
```dart
Future<List<Product>> fetchProducts() async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/products'))
        .timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

---

### #12 Streams & BLOC Pattern
**Deskripsi**: Kemampuan mengelola state dengan stream dan BLOC Pattern di Flutter.

**Tujuan**: Implementasi state management yang scalable dan reactive untuk aplikasi yang kompleks.

**Implementasi**:
- BLOC Pattern dengan `flutter_bloc` package
- Fitur:
  - Event-driven architecture
  - State stream untuk reaktif UI
  - Separation of concerns (Business Logic vs UI)
  - Real-time data binding dengan Streams
  - Chat messaging dengan Stream

**Lokasi kode**:
- BLOC: `pbl_new/lib/features/chat/bloc/`
- Stream listeners: `pbl_new/lib/features/*/presentation/pages/`

**Contoh**:
```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  
  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadMessagesEvent>((event, emit) async {
      emit(ChatLoading());
      try {
        final messages = await repository.getMessages(event.chatId);
        emit(ChatLoaded(messages));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });
  }
}
```

---

### #13 Persistensi Data
**Deskripsi**: Kemampuan mengelola data JSON dan persistensi data di Flutter.

**Tujuan**: Menyimpan data lokal untuk offline support dan cache data dari API.

**Implementasi**:
- Tools:
  - `shared_preferences` untuk preferensi pengguna
  - `sqflite` untuk database lokal
  - `hive` untuk caching data kompleks
  - JSON serialization/deserialization

**Fitur**:
  - Simpan token autentikasi
  - Cache produk lokal
  - Draft chat messages
  - User preferences (tema, bahasa)

**Lokasi kode**: 
- Models: `pbl_new/lib/core/models/`
- Local DB: `pbl_new/lib/services/local_database_service.dart`

**Contoh**:
```dart
// SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
final savedToken = prefs.getString('auth_token');

// Hive
final box = await Hive.openBox('products');
await box.put('products_list', productsJson);
final cached = box.get('products_list');

// JSON Serialization
class Product {
  final String id;
  final String name;
  
  Product.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

---

### #14 Restful API
**Deskripsi**: Kemampuan menerapkan komunikasi melalui internet dengan RESTful API di Flutter.

**Tujuan**: Koneksi dengan backend server untuk CRUD operasi data marketplace.

**Implementasi**:
- HTTP Client: `http` package / `dio` package
- Fitur:
  - GET requests untuk fetch data (products, users, chats)
  - POST requests untuk create data (upload produk, pesan)
  - PUT/PATCH requests untuk update data
  - DELETE requests untuk hapus data
  - Authentication header (Bearer token)
  - Request/response interceptors
  - Error handling dan response parsing

**Lokasi kode**: `pbl_new/lib/services/api_service.dart`

**Contoh**:
```dart
class ApiService {
  static const String baseUrl = 'https://api.marketplace.local';
  final http.Client _client;
  
  // GET - Fetch products
  Future<List<Product>> getProducts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body)['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }
    throw Exception('Failed to load products');
  }
  
  // POST - Upload produk
  Future<Product> createProduct(Product product) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body)['data']);
    }
    throw Exception('Failed to create product');
  }
  
  // PUT - Update produk
  Future<Product> updateProduct(String id, Product product) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body)['data']);
    }
    throw Exception('Failed to update product');
  }
  
  // DELETE - Hapus produk
  Future<void> deleteProduct(String id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
```

**API Endpoints**:
- `GET /api/products` — Daftar semua produk
- `GET /api/products/{id}` — Detail produk
- `POST /api/products` — Buat produk baru
- `PUT /api/products/{id}` — Update produk
- `DELETE /api/products/{id}` — Hapus produk
- `GET /api/users/{id}` — Detail pengguna
- `POST /api/auth/login` — Login
- `POST /api/messages` — Kirim pesan
- `GET /api/messages/{chatId}` — Ambil pesan

---

## Implementasi Fitur PCVK (Pengolahan Citra Visi Komputer)

### Clothing Detection dengan Machine Learning

**Deskripsi**: Implementasi fitur deteksi otomatis kategori pakaian menggunakan teknik Pengolahan Citra Visi Komputer.

**Tujuan**: Mengotomatisasi kategorisasi produk pakaian saat pengguna upload foto, meningkatkan akurasi dan kecepatan proses listing produk.

**Teknologi**:
- **Ekstraksi Fitur**: HOG (Histogram of Oriented Gradients)
- **Klasifikasi**: Linear SVM (Support Vector Machine)
- **Framework ML**: scikit-learn
- **Deployment**: REST API di Hugging Face Spaces + Backend PHP

**Kelas Deteksi** (4 kategori):
1. Hat (Topi)
2. Shirt (Kemeja)
3. Shoes (Sepatu)
4. T-Shirt (Kaos)

**Performa Model**:
- Training Accuracy: 98,71%
- Validation Accuracy: 77,69%
- **Test Accuracy: 96,99%**
- Macro Precision/Recall/F1: 0,969 / 0,951 / 0,960
- Micro Precision/Recall/F1 (equals accuracy): 0,970

**Confusion Matrix** (Test Set):
```
           Hat  Shirt  Shoes  T-Shirt
Hat         30      0      2        2
Shirt        1     73      0        2
Shoes        0      0     84        2
T-Shirt      0      2      1      200
```

**Fitur Implementasi**:

#### 1. Frontend Integration (Flutter)
- **Kamera Integration**: Tangkap foto pakaian
- **Image Preview**: Tampilkan preview sebelum proses
- **Loading State**: Indikator proses saat mengirim ke API
- **Result Display**: Tampilkan kategori prediksi + confidence score
- **Confidence Indicator**: Visual indicator akurasi prediksi

**Lokasi kode**: 
- Service: `pbl_new/lib/services/clothing_detection_service.dart`
- UI Page: `pbl_new/lib/features/warga/presentation/pages/clothing_detection_page.dart`

**Contoh kode**:
```dart
class ClothingDetectionService {
  Future<ClothingDetectionResult> detectClothing(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/detect_clothing'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return ClothingDetectionResult.fromJson(data);
      } else {
        throw Exception('Detection failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

#### 2. Backend API (PHP)
- **Endpoint**: `POST /api/ml/detect_clothing`
- **Input**: Gambar (multipart/form-data)
- **Output**: JSON dengan kategori prediksi, confidence, dan metadata
- **Integration**: Memanggil Python ML API di Hugging Face

**Lokasi kode**: `pbl_new/backend/ml_detection.php`

```php
<?php
// PHP ML Detection API
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['image'])) {
    $tempFile = $_FILES['image']['tmp_name'];
    $filename = basename($_FILES['image']['name']);
    
    // Kirim ke Hugging Face API
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'https://huggingface-space-api/predict');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, [
        'image' => new CURLFile($tempFile, 'image/jpeg', $filename),
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    echo $response;
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid request']);
}
?>
```

#### 3. ML Model Service (Hugging Face Spaces)
- **Framework**: Flask / Gradio
- **Model**: Pre-trained HOG + SVM model
- **Input**: Image (JPG/PNG)
- **Output**: JSON dengan prediksi kategori dan confidence scores

**Lokasi kode**: `huggingface_deployment/clothing-detection/app.py`

```python
from flask import Flask, request, jsonify
import joblib
import cv2
import numpy as np
from skimage.feature import hog

app = Flask(__name__)

# Load model dan scaler
model = joblib.load('models/clothing_svm_best.pkl')
scaler = joblib.load('models/clothing_scaler_best.pkl')
label_mapping = {0: 'Hat', 1: 'Shirt', 2: 'Shoes', 3: 'T-Shirt'}

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    file = request.files['image']
    img = cv2.imread(file.stream)
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_resized = cv2.resize(img_gray, (128, 128))
    
    # Extract HOG features
    features = hog(img_resized, orientations=9, pixels_per_cell=(8, 8),
                   cells_per_block=(2, 2), transform_sqrt=True)
    features_scaled = scaler.transform([features])
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    return jsonify({
        'category': label_mapping[prediction],
        'confidence': float(probabilities[prediction]),
        'all_probabilities': {
            label_mapping[i]: float(p) for i, p in enumerate(probabilities)
        },
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

#### 4. Demo Visual (GIF)
**Deskripsi**: Animasi demonstrasi alur penggunaan fitur clothing detection.

**Skenario GIF**:
1. Pengguna membuka halaman upload produk
2. Tap tombol "Ambil Foto" → Kamera terbuka
3. Ambil foto pakaian → Preview ditampilkan
4. Tap "Deteksi Kategori" → Loading indicator
5. Hasil deteksi muncul: "T-Shirt (95% confidence)"
6. Kategori otomatis terisi di form produk
7. Pengguna dapat edit/confirm dan submit

**Lokasi file**: 
- GIF demo: `images/ml_report/clothing-detection-demo.gif`
- Screenshots: 
  - `images/ml_report/screenshot-01-camera.png`
  - `images/ml_report/screenshot-02-preview.png`
  - `images/ml_report/screenshot-03-result.png`

**Tools GIF**:
- Dibuat dengan: ScreenToGif, FFmpeg, atau Gifify
- Format: MP4 → GIF conversion
- Duration: 5-10 detik per siklus

---

## Fitur-Fitur Terintegrasi

### Integrasi Mobile + PCVK

**Alur Lengkap Upload Produk dengan Auto-Kategorisasi**:

1. **User membuka halaman "Jual Produk"**
   - UI form dengan field: nama, deskripsi, harga, foto
   - Tombol "Ambil Foto" atau "Pilih dari Galeri"

2. **Ambil/Pilih Foto**
   - Camera plugin terbuka (jika ambil foto)
   - Image picker terbuka (jika pilih galeri)

3. **Preview Foto**
   - Tampilkan preview foto di form
   - User dapat retake atau lanjut

4. **Deteksi Kategori (PCVK)**
   - Tap tombol "Deteksi Kategori Otomatis"
   - Foto dikirim ke backend API
   - Backend memanggil ML API di Hugging Face
   - ML API menjalankan model HOG + SVM

5. **Hasil Deteksi**
   - Kategori diprediksi (Hat/Shirt/Shoes/T-Shirt)
   - Confidence score ditampilkan
   - Kategori otomatis terisi di dropdown form

6. **Review & Validasi**
   - User dapat ubah kategori manual jika diperlukan
   - Tambah deskripsi, harga, dll
   - Submit form

7. **Simpan Produk**
   - Data produk (termasuk kategori prediksi) disimpan ke backend
   - Foto diupload ke cloud storage
   - Notifikasi sukses

---

## Struktur Direktori

```
d:\CloneGithub\New_PBL_Jawara\
├── pbl_new/                          # Aplikasi mobile Flutter
│   ├── lib/
│   │   ├── features/
│   │   │   ├── warga/
│   │   │   │   ├── presentation/
│   │   │   │   │   ├── pages/
│   │   │   │   │   │   ├── clothing_detection_page.dart
│   │   │   │   │   │   └── upload_product_page.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── camera_widget.dart
│   │   │   │   └── bloc/
│   │   │   ├── chat/
│   │   │   │   └── bloc/
│   │   │   └── auth/
│   │   │       └── bloc/
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── clothing_detection_service.dart
│   │   │   ├── firebase_service.dart
│   │   │   └── local_database_service.dart
│   │   ├── core/
│   │   │   └── models/
│   │   │       ├── product_model.dart
│   │   │       ├── user_model.dart
│   │   │       └── clothing_detection_result.dart
│   │   ├── config/
│   │   │   └── api_config.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── pubspec.lock
│
├── backend/                           # Backend API (PHP)
│   ├── ml_detection.php
│   ├── products.php
│   ├── users.php
│   ├── config.php
│   └── database.sql
│
├── ml_training/                       # ML Training & Model
│   ├── scripts/
│   │   ├── train_model.py
│   │   ├── evaluate.py
│   │   └── predict.py
│   ├── models/
│   │   ├── clothing_svm_best.pkl
│   │   ├── clothing_scaler_best.pkl
│   │   └── label_mapping.json
│   ├── output/
│   │   ├── confusion_matrix.npy
│   │   ├── y_true.npy
│   │   └── y_pred.npy
│   └── dataset/
│       └── Filtered_Image/
│
├── huggingface_deployment/            # ML API Deployment
│   ├── clothing-detection/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── README.md
│
├── images/                            # Assets & Documentation
│   └── ml_report/
│       ├── fig-01-dataset-samples.jpg
│       ├── fig-02-pipeline.png
│       ├── fig-03-sample-prediction.png
│       ├── clothing-detection-demo.gif
│       ├── screenshot-01-camera.png
│       ├── screenshot-02-preview.png
│       └── screenshot-03-result.png
│
├── README.md
├── README_LAPORAN_ML.md
├── README_LAPORAN_ML_EN.md
└── README_LAPORAN_MOBILE+PCVK.md   # File ini
```

---

## Teknologi Stack

### Mobile (Flutter)
- **Language**: Dart 3.x
- **Framework**: Flutter 3.x
- **State Management**: Provider + BLOC Pattern
- **Networking**: http / dio
- **Local Storage**: shared_preferences, sqflite, hive
- **Camera**: image_picker, camera
- **Firebase**: firebase_core, firebase_auth, firebase_messaging

### Backend (PHP)
- **Language**: PHP 7.4+
- **Database**: MySQL / MariaDB
- **API Pattern**: RESTful
- **Authentication**: JWT (JSON Web Token)
- **HTTP Client**: cURL

### Machine Learning
- **Language**: Python 3.x
- **ML Framework**: scikit-learn
- **Image Processing**: OpenCV, scikit-image
- **Model Serialization**: joblib
- **Deployment**: Flask/Gradio, Docker, Hugging Face Spaces

### DevOps & Cloud
- **Version Control**: Git (GitHub)
- **Container**: Docker
- **Cloud Hosting**: Hugging Face Spaces (ML API)
- **Backend Hosting**: XAMPP (Local Development)
- **Authentication**: Firebase Auth
- **Real-time DB**: Firebase Realtime Database

---

## Panduan Implementasi

### Menjalankan Aplikasi Mobile

1. **Setup Flutter Environment**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Build APK untuk Android**
   ```bash
   flutter build apk --release
   ```

3. **Build IPA untuk iOS**
   ```bash
   flutter build ios --release
   ```

### Menjalankan Backend API

1. **Setup XAMPP**
   - Install XAMPP dan start Apache + MySQL
   - Copy direktori `backend/` ke `htdocs/`

2. **Setup Database**
   ```bash
   mysql -u root < backend/database.sql
   ```

3. **Test API**
   ```bash
   curl -X GET http://localhost/backend/products.php
   ```

### Menjalankan ML Model (Local Development)

1. **Setup Python Environment**
   ```bash
   cd ml_training/scripts
   pip install -r ../requirements.txt
   ```

2. **Train Model**
   ```bash
   python train_model.py
   ```

3. **Evaluate Model**
   ```bash
   python evaluate.py
   ```

4. **Run Prediction Service**
   ```bash
   cd ../../huggingface_deployment/clothing-detection
   pip install -r requirements.txt
   python app.py
   ```

---

## Kesimpulan

Proyek ini mendemonstrasikan integrasi penuh antara **aplikasi mobile modern (Flutter)**, **backend RESTful API (PHP)**, dan **machine learning praktis (Scikit-learn)** untuk membangun solusi real-world yang berguna.

Fokus utama pada **Clothing Detection dengan PCVK** menunjukkan bagaimana teknik computer vision dapat diaplikasikan untuk meningkatkan user experience dan efisiensi operasional marketplace.

Dengan arsitektur modular dan well-documented, proyek ini siap untuk:
- ✅ Dideploykan ke production
- ✅ Diperluas dengan fitur tambahan
- ✅ Ditingkatkan performa model ML
- ✅ Dioptimalkan untuk berbagai devices

---

## Kontak & Support

Untuk pertanyaan atau kontribusi, silakan hubungi tim melalui:
- **Email**: info@pbljawaramarketplace.id
- **GitHub**: https://github.com/CrushedKatana/New_PBL_Jawara
- **Documentation**: Lihat README.md, README_LAPORAN_ML.md, dan README_LAPORAN_MOBILE+PCVK.md

---

**Dibuat dengan ❤️ oleh Tim PBL Jawara**  
*Desember 2025*
