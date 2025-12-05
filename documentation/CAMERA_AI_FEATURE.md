# Fitur Deteksi Kamera AI - Jawara Marketplace

## 📸 Overview
Fitur deteksi kamera AI otomatis mendeteksi kategori pakaian menggunakan Google ML Kit Image Labeling.

## ✨ Fitur

### 1. **Kamera Preview Real-time**
- Tampilan kamera full-screen dengan overlay frame kuning
- UI mirip dengan screenshot yang diberikan
- Indikator "PCVK Active" menunjukkan AI detection aktif

### 2. **Deteksi Kategori Otomatis**
- Menggunakan Google ML Kit Image Labeling
- Mendeteksi berbagai jenis pakaian:
  - Atasan (Shirt, T-shirt, Sweater)
  - Celana (Pants, Jeans, Shorts)
  - Dress
  - Jaket (Jacket, Coat)
  - Rok (Skirt)
  - Sepatu (Shoes, Footwear)
  - Tas (Bag, Handbag, Backpack)
  - Aksesoris (Hat, Cap, Socks)

### 3. **Confidence Score**
- Menampilkan persentase akurasi deteksi
- Hanya menampilkan hasil dengan confidence > 50%

### 4. **Integrasi dengan Add Product**
- Foto yang diambil langsung ditambahkan ke form
- Kategori otomatis terisi berdasarkan hasil deteksi
- Notifikasi menampilkan kategori yang terdeteksi

## 🚀 Cara Menggunakan

### Di Add Product Screen:
1. Klik tombol **"AI Deteksi"** (dengan icon ✨)
2. Arahkan kamera ke pakaian yang akan dijual
3. Frame kuning akan membantu positioning
4. Tekan tombol capture (bulat putih dengan border kuning)
5. Tunggu proses deteksi (loading indicator)
6. Review hasil:
   - Foto yang diambil
   - Kategori yang terdeteksi + confidence score
7. Pilih **"Gunakan Foto"** atau **"Foto Ulang"**
8. Kembali ke form dengan foto dan kategori sudah terisi

## 🔧 Dependencies Baru

```yaml
camera: ^0.11.0+2                      # Camera access
path_provider: ^2.1.4                  # File paths
path: ^1.9.0                           # Path utilities
google_mlkit_image_labeling: ^0.12.0  # ML Kit Image Labeling
```

## 📱 Permissions

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk mengambil foto produk dan mendeteksi kategori pakaian secara otomatis</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk memilih foto produk</string>
```

## 📁 File Structure

```
lib/
├── screens/
│   ├── add_product_screen.dart      # Updated dengan AI Deteksi button
│   └── camera_detection_screen.dart # NEW: Camera & AI detection
```

## 🎯 Category Mapping

AI mengenali label dalam bahasa Inggris dan mengkonversi ke kategori Indonesia:

| Detected Label | Kategori Indonesia |
|----------------|-------------------|
| shirt, t-shirt, sweater, top | Atasan |
| pants, jeans, shorts | Celana |
| dress | Dress |
| jacket, coat | Jaket |
| skirt | Rok |
| shoe, footwear | Sepatu |
| bag, handbag, backpack | Tas |
| hat, cap, socks | Aksesoris |
| clothing (generic) | Pakaian |

## 🔄 Workflow

```
1. User clicks "AI Deteksi" button
   ↓
2. CameraDetectionScreen opens
   ↓
3. User aims camera at clothing item
   ↓
4. User taps capture button
   ↓
5. Image is captured & processed with ML Kit
   ↓
6. Category is detected with confidence score
   ↓
7. User confirms or retakes photo
   ↓
8. Returns to AddProductScreen with:
   - image: File
   - category: String (matched to CategoryModel)
   - confidence: double (0.0 - 1.0)
```

## ⚡ Performance

- **Detection Time**: ~1-2 seconds
- **Accuracy**: Depends on image quality and lighting
- **Offline**: ML Kit dapat berjalan offline (model on-device)

## 🎨 UI Components

### Camera Screen
- **Header**: Title + description
- **Detection Frame**: Yellow rounded border (80% screen width)
- **Result Badge**: Blue pill showing detected category + confidence
- **Bottom Controls**: 
  - Batal button
  - Capture button (large circular)
  - PCVK Active indicator

### After Capture
- **Preview**: Captured image
- **Buttons**: Foto Ulang | Gunakan Foto

## 🐛 Known Limitations

1. **Lighting**: Deteksi lebih baik dengan pencahayaan yang cukup
2. **Complex Patterns**: Pakaian dengan pattern rumit mungkin sulit dideteksi
3. **Category Mapping**: Jika ML Kit tidak mendeteksi clothing-related label, default ke "Pakaian"
4. **Single Detection**: Saat ini hanya mendeteksi 1 kategori dominan

## 📝 Notes

- Deteksi menggunakan on-device ML model (tidak perlu internet)
- Category mapping dapat disesuaikan di `_categoryMapping` 
- Confidence threshold di-set 50% (dapat disesuaikan)
- Kompatibel dengan semua kategori yang ada di database
