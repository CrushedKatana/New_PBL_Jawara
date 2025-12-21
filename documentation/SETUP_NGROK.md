# Setup Ngrok untuk Backend PBL Jawara

## 1. Download & Install Ngrok

1. **Download Ngrok:**
   - Kunjungi: https://ngrok.com/download
   - Download versi Windows (ZIP file)

2. **Extract & Setup:**
   ```cmd
   # Extract ngrok.exe ke folder (contoh: C:\ngrok)
   # Atau bisa taruh di folder project
   ```

3. **Sign Up & Get Auth Token:**
   - Buat akun gratis di: https://dashboard.ngrok.com/signup
   - Copy auth token dari: https://dashboard.ngrok.com/get-started/your-authtoken

4. **Configure Auth Token:**
   ```cmd
   cd C:\ngrok
   ngrok config add-authtoken YOUR_AUTH_TOKEN
   ```

---

## 2. Start XAMPP Backend

Pastikan XAMPP sudah running:
```
Apache: Port 80 (atau port custom Anda)
MySQL: Port 3306
```

Test backend di browser:
```
http://localhost/marketplace_api/auth.php
```

---

## 3. Start Ngrok Tunnel

```cmd
# Jika backend di localhost:80/marketplace_api
ngrok http 80

# Atau jika pakai port custom (misal 8080)
ngrok http 8080
```

**Output akan seperti ini:**
```
ngrok

Session Status                online
Account                       your_email@example.com
Version                       3.x.x
Region                        United States (us)
Latency                       45ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://xxxx-xxxx-xxxx.ngrok-free.app -> http://localhost:80

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**COPY URL ini:** `https://xxxx-xxxx-xxxx.ngrok-free.app`

---

## 4. Update Flutter App Config

### Option A: Manual Update (Cepat)

Edit `lib/config/api_config.dart`:

```dart
static String _resolveBaseUrl() {
  const envBase = String.fromEnvironment('API_BASE_URL');
  if (envBase.isNotEmpty) return envBase;

  // NGROK URL - Update dengan URL dari ngrok
  return 'https://xxxx-xxxx-xxxx.ngrok-free.app/marketplace_api';
  
  // Original LAN
  // if (kIsWeb) {
  //   return 'http://$networkIp/jawara/backend';
  // }
  // return 'http://$networkIp/jawara/backend';
}
```

### Option B: Environment Variable (Flexible)

Run app dengan ngrok URL:
```bash
flutter run --dart-define=API_BASE_URL=https://xxxx-xxxx-xxxx.ngrok-free.app/marketplace_api
```

---

## 5. Test Connection

### Test di Browser:
```
https://xxxx-xxxx-xxxx.ngrok-free.app/marketplace_api/auth.php
```

Should return PHP response (not 404).

### Test dari Flutter App:
1. Hot restart app: `R` di terminal
2. Try login atau load products
3. Check console logs untuk koneksi

---

## 6. Troubleshooting

### Error: "Invalid Host Header"
Jika muncul error ini, tambahkan config ngrok:

Buat file `ngrok.yml`:
```yaml
version: "2"
authtoken: YOUR_AUTH_TOKEN
tunnels:
  backend:
    proto: http
    addr: 80
    host_header: rewrite
```

Run dengan:
```cmd
ngrok start backend
```

### Error: CORS (Cross-Origin)
Tambahkan header di PHP backend (`auth.php`, `products.php`, dll):

```php
<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ... rest of code
```

### Ngrok Free Tier Limitations:
- **Session expires:** Ngrok free restarts setiap 2 jam (URL berubah)
- **Solution:** Update URL di `api_config.dart` setiap kali restart
- **Better:** Pakai env variable untuk gampang ganti URL

---

## 7. Production Alternative (Tidak Pakai Ngrok)

### Option A: Deploy Backend ke Cloud
- **Hosting:** 000webhost, InfinityFree, Heroku
- **Database:** Remote MySQL
- **Cost:** Gratis - $5/bulan

### Option B: VPS
- **Provider:** DigitalOcean, Vultr, AWS EC2
- **Setup:** LAMP stack + domain
- **Cost:** $5-10/bulan

---

## Quick Command Reference

```bash
# Install ngrok
choco install ngrok  # (if using Chocolatey)
# OR download from https://ngrok.com/download

# Setup auth
ngrok config add-authtoken YOUR_TOKEN

# Start tunnel
ngrok http 80

# Check web interface
http://localhost:4040

# Run Flutter with ngrok URL
flutter run --dart-define=API_BASE_URL=https://xxxx.ngrok-free.app/marketplace_api
```

---

## Tips

1. **Ngrok Web Interface:** Buka `http://localhost:4040` untuk monitor requests
2. **Keep Terminal Open:** Jangan close terminal ngrok saat testing
3. **Share URL:** Bisa kasih URL ke teman untuk test dari HP mereka
4. **SSL Included:** Ngrok sudah provide HTTPS gratis
5. **Backend Logs:** Check XAMPP error logs jika ada issue

---

## Next Steps

1. Download ngrok dari link di atas
2. Setup auth token
3. Start ngrok: `ngrok http 80`
4. Copy URL yang muncul
5. Update `api_config.dart` dengan URL tersebut
6. Hot restart Flutter app
7. Test!

**Ngrok URL akan berubah setiap restart** (free tier), jadi simpan command untuk gampang update.
