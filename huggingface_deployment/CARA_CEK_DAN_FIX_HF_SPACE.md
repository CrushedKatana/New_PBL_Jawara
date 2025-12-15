# 📋 Cara Cek dan Fix Hugging Face Space (Error 503)

## Langkah 1: Cek Status Space

### Via Browser
1. Buka: https://huggingface.co/spaces/crushedkatana/clothing-detection
2. Login dengan akun Hugging Face kamu
3. Lihat status di atas:
   - 🟢 **Running** → OK, Space hidup
   - 🔴 **Error** → Ada masalah, perlu fix
   - 🟡 **Building** → Sedang rebuild, tunggu 2-3 menit

## Langkah 2: Lihat Logs

1. Di halaman Space, klik tab **"Logs"**
2. Lihat error message terakhir (warna merah)
3. Error umum:

### Error A: Module Not Found
```
ModuleNotFoundError: No module named 'sklearn'
```
**Fix:** Edit `requirements.txt`, tambahkan package yang kurang

### Error B: Out of Memory
```
Killed (Out of Memory)
```
**Fix:** 
- Resize image sebelum upload (max 800x800px)
- Atau upgrade Space ke paid tier

### Error C: Port Error
```
Address already in use
```
**Fix:** Factory reboot (lihat Langkah 3)

## Langkah 3: Factory Reboot

1. Klik **⚙️ Settings** (pojok kanan atas Space)
2. Scroll ke bawah sampai lihat **"Factory Reboot"**
3. Klik tombol **"Factory Reboot"**
4. Tunggu 2-3 menit
5. Refresh halaman, status harusnya jadi 🟢 Running

## Langkah 4: Test Space

### Test via UI (mudah)
1. Di halaman Space, klik **"App"** tab
2. Upload foto pakaian (T-shirt, Kemeja, Sepatu, Topi)
3. Lihat hasil deteksi

### Test via API (advanced)
```bash
# Windows PowerShell
curl.exe -X POST "https://crushedkatana-clothing-detection.hf.space/detect" -F "data=@C:\path\to\image.jpg"

# Linux/Mac
curl -X POST "https://crushedkatana-clothing-detection.hf.space/detect" -F "data=@/path/to/image.jpg"
```

Response sukses:
```json
{
  "data": ["{\"success\": true, \"predicted_class\": \"Topi\", \"confidence\": 0.95}"]
}
```

## Langkah 5: Update Flutter App (Jika perlu ganti endpoint)

Jika Space tetap error, gunakan endpoint cadangan atau local:

1. Buka file: `pbl_new/lib/config/api_config.dart`
2. Edit baris ini:

```dart
// Ganti dengan local server (jika ada)
static String get mlDetectionEndpoint => 'http://192.168.1.2:5000/detect';

// Atau keep HF Space (tunggu fix)
static String get mlDetectionEndpoint => 'https://crushedkatana-clothing-detection.hf.space/detect';
```

3. Save dan rebuild app:
```bash
cd pbl_new
flutter clean
flutter pub get
flutter run
```

## Troubleshooting Tambahan

### Problem: "Cold Start" Timeout
**Gejala:** Error timeout di deteksi pertama, tapi retry ke-2 sukses

**Penyebab:** Space free tier tidur setelah 48 jam tidak dipakai

**Fix:** 
- ✅ App sudah ada auto-retry (tunggu saja)
- Atau buka Space di browser dulu untuk "warm up"

### Problem: Error 502/504
**Gejala:** Gateway timeout

**Fix:**
- Cek status HF: https://status.huggingface.co
- Tunggu 5-10 menit (infrastructure issue)
- Resize image lebih kecil (<500KB)

### Problem: App error tapi browser OK
**Gejala:** Test di browser Space berhasil, tapi app error

**Fix:**
- Cek internet device (WiFi/mobile data)
- Cek firewall/antivirus
- Restart app

## Video Tutorial (Jika Perlu)

### Cara Cek Space Status (30 detik)
1. Login HF → Spaces → Pilih space kamu
2. Lihat indicator warna
3. Klik Logs untuk detail

### Cara Factory Reboot (1 menit)
1. Settings → Scroll bawah
2. Factory Reboot → Confirm
3. Tunggu rebuild selesai

### Cara Deploy Ulang (5 menit)
```bash
# Clone space
git clone https://huggingface.co/spaces/crushedkatana/clothing-detection
cd clothing-detection

# Edit jika perlu
# nano app.py

# Push update
git add .
git commit -m "Fix space"
git push
```

## Kontak

Jika masih bingung:
1. Screenshot error + logs
2. Tanya di group/forum
3. Atau buat issue GitHub

**Note:** Hugging Face free tier kadang lambat/unstable. Jika butuh production-ready, consider:
- Upgrade ke paid tier ($9/bulan)
- Deploy di Google Cloud Run
- Deploy di server sendiri
