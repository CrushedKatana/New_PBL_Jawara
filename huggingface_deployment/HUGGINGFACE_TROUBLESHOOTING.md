# 🔧 Panduan Troubleshooting Hugging Face Space

## Error 503: "Your space is in error"

Error ini terjadi ketika Hugging Face Space mengalami masalah. Berikut cara mengatasinya:

### 1. Cek Status Space

1. Buka browser dan kunjungi:
   ```
   https://huggingface.co/spaces/crushedkatana/clothing-detection
   ```

2. Lihat indicator status di bagian atas:
   - 🟢 **Running** = Normal, seharusnya bisa digunakan
   - 🔴 **Error/Building** = Space sedang bermasalah
   - 🟡 **Starting** = Space sedang cold start (tunggu 1-2 menit)

### 2. Cek Logs Space

1. Di halaman Space, klik tab **"Logs"** (di sebelah tab Files)
2. Scroll ke bawah untuk lihat error terbaru
3. Cari pesan error yang berisi:
   - `ModuleNotFoundError` = Package tidak terinstall
   - `Out of memory` = Space kehabisan RAM
   - `Port already in use` = Konflik port

### 3. Rebuild Space (Jika Error Persisten)

#### Cara 1: Factory Reboot via UI

1. Klik **Settings** (⚙️) di kanan atas Space
2. Scroll ke bawah, klik **"Factory Reboot"**
3. Tunggu 2-3 menit sampai Space rebuild

#### Cara 2: Restart dari Terminal (Jika punya akses)

```bash
# Di halaman Space, buka console/terminal
# Tekan Ctrl+C untuk stop, lalu:
python app.py
```

### 4. Verifikasi Dependencies

Pastikan file `requirements.txt` di Space sudah benar:

```txt
Flask==3.0.0
gunicorn==21.2.0
scikit-learn==1.3.2
scikit-image==0.22.0
opencv-python-headless==4.8.1.78
numpy==1.24.3
Pillow==10.1.0
```

Jika ada yang kurang/salah:
1. Edit file `requirements.txt` via web editor HF
2. Commit changes
3. Space akan auto-rebuild

### 5. Cek Resource Limits

Hugging Face Free Tier memiliki batasan:
- **RAM**: 16GB
- **CPU**: 2 cores
- **Disk**: 50GB
- **Timeout**: 60 detik per request

Jika model terlalu besar atau image terlalu besar:
- Resize image sebelum kirim (max 1MB, 800x800px)
- Upgrade Space ke paid tier jika perlu

### 6. Alternative: Gunakan Local Deployment

Jika HF Space terus error, deploy lokal:

```bash
cd clothing-detection-api
python app.py
```

Lalu update `api_config.dart`:

```dart
static String get mlDetectionEndpoint => 'http://192.168.1.2:5000/detect';
```

---

## Error Timeout / Cold Start

### Penyebab
- Space free tier "tidur" setelah tidak dipakai 48 jam
- Saat pertama kali diakses, butuh waktu 1-2 menit untuk "bangun"

### Solusi
1. **Tunggu 1-2 menit** setelah error pertama, lalu coba lagi
2. App sudah ada **auto-retry** dengan delay 2-4 detik
3. Jika masih gagal, buka Space di browser dulu untuk "warm up"

---

## Error 502/504 Gateway Timeout

### Penyebab
- Request terlalu lama (>60s)
- Space sedang restart
- Hugging Face infrastructure issue

### Solusi
1. Resize image lebih kecil (<500KB)
2. Tunggu 5 menit, coba lagi
3. Cek status Hugging Face: https://status.huggingface.co

---

## Test Manual via Browser

Buka di browser:
```
https://crushedkatana-clothing-detection.hf.space
```

Upload gambar via UI. Jika berhasil di browser tapi gagal di app:
- Masalah di app/network, bukan di Space
- Cek koneksi internet device
- Cek firewall/proxy

---

## Test via cURL (untuk Debug)

```bash
curl -X POST "https://crushedkatana-clothing-detection.hf.space/detect" \
  -F "data=@/path/to/image.jpg"
```

Response normal:
```json
{
  "data": ["{\"success\": true, \"predicted_class\": \"Topi\", \"confidence\": 0.95}"]
}
```

Response error:
```json
{
  "error": "..."
}
```

---

## Cara Deploy Ulang dari Awal

Jika semua gagal, deploy ulang Space:

### 1. Clone Repo

```bash
git clone https://huggingface.co/spaces/crushedkatana/clothing-detection
cd clothing-detection
```

### 2. Pastikan File Lengkap

Minimal files:
- `app.py` - Flask API
- `requirements.txt` - Dependencies
- `label_mapping.json` - Category mapping
- `models/` - Folder berisi `.pkl` model
- `README.md` - Space description

### 3. Push Changes

```bash
git add .
git commit -m "Fix: rebuild space"
git push
```

Space akan auto-rebuild dalam 2-3 menit.

---

## Kontak Support

Jika masalah berlanjut:
1. Screenshot error dari app + logs dari HF Space
2. Buat issue di repo GitHub
3. Atau hubungi Hugging Face support: https://huggingface.co/support

---

## Quick Checklist

- [ ] Space status = Running (hijau)
- [ ] Logs tidak ada error merah
- [ ] Test manual di browser berhasil
- [ ] Image size < 1MB
- [ ] Internet connection stabil
- [ ] Sudah tunggu 2 menit setelah cold start
- [ ] Sudah coba 2-3x (ada auto-retry)

Jika semua checklist OK tapi masih error, kemungkinan HF infrastructure issue. Coba lagi 30 menit kemudian.
