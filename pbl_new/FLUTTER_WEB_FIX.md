# Fix: Multiple Chrome Tabs saat Flutter Web Run

## Masalah
Saat `flutter run -d chrome`, muncul 4 tab sekaligus dan app tidak keluar apa-apa.

## Penyebab
1. **Hot reload Flutter web** membuka tab baru instead of refresh
2. **Chrome cache** yang corrupt
3. **Multiple flutter run** commands dijalankan bersamaan

## Solusi

### 1. Clean & Restart Flutter
```bash
# Stop semua Flutter processes
flutter clean

# Hapus build cache
rmdir /S /Q build

# Run dengan flag yang benar
flutter run -d chrome --web-renderer html
```

### 2. Gunakan `--web-hostname` dan `--web-port`
```bash
# Fix port untuk prevent multiple instances
flutter run -d chrome --web-hostname localhost --web-port 8080 --web-renderer html
```

### 3. Disable Hot Reload Auto-Open
Edit `.vscode/launch.json` (jika ada):
```json
{
  "configurations": [
    {
      "name": "pbl_new",
      "request": "launch",
      "type": "dart",
      "args": [
        "--web-renderer",
        "html",
        "--web-browser-flag",
        "--disable-web-security"
      ]
    }
  ]
}
```

### 4. Chrome Settings untuk Flutter Web
```bash
# Run dengan Chrome flags untuk prevent new tabs
flutter run -d chrome --web-renderer html --web-browser-flag="--new-window" --web-browser-flag="--disable-extensions"
```

### 5. Gunakan Edge atau Firefox (Alternatif)
```bash
# Jika Chrome bermasalah, gunakan Edge
flutter run -d edge --web-renderer html

# Atau
flutter devices  # Lihat available devices
flutter run -d <device-id>
```

## Quick Fix (Recommended)

### Step 1: Clean Project
```bash
cd d:\CloneGithub\New_PBL_Jawara\pbl_new
flutter clean
```

### Step 2: Kill All Chrome
```bash
taskkill /F /IM chrome.exe
```

### Step 3: Run dengan Port Fixed
```bash
flutter run -d chrome --web-hostname localhost --web-port 8080 --web-renderer html
```

### Step 4: Jangan Hot Reload! Gunakan Hot Restart
- Press `R` (Hot Restart) instead of `r` (Hot Reload)
- Hot Restart tidak buka tab baru

## Prevention

### Option 1: Gunakan Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```
Kemudian run app dan connect via DevTools UI.

### Option 2: Build Release dan Serve Manual
```bash
# Build release
flutter build web --web-renderer html

# Serve dengan http-server
cd build/web
npx http-server -p 8080
```
Buka manual: `http://localhost:8080`

### Option 3: Disable Auto-Open Browser
```bash
# Run tanpa auto-open browser
flutter run -d web-server --web-hostname localhost --web-port 8080

# Buka manual di browser:
# http://localhost:8080
```

## Debug: Cek Kenapa App Tidak Keluar Apa-apa

### 1. Cek Console Browser
- Buka DevTools di Chrome: `F12`
- Lihat tab Console untuk error messages
- Lihat tab Network untuk failed requests

### 2. Cek Build Output
```bash
# Run dengan verbose
flutter run -d chrome -v
```
Lihat error di terminal.

### 3. Test dengan Simple Screen
Tambah di main.dart untuk debug:
```dart
home: Scaffold(
  body: Center(
    child: Text('Test - App Working!'),
  ),
),
```

Jika muncul, berarti masalah di SplashScreen atau routing.

## Catatan Khusus untuk Project Ini

Project ini menggunakan:
- Firebase (bisa timeout dan freeze app)
- Custom routing
- SplashScreen

### Potential Issues:

#### 1. Firebase Timeout
Di `main.dart` line 28-43, Firebase init bisa freeze:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
).timeout(const Duration(seconds: 10));
```

**Fix:** Sudah ada timeout handler, tapi cek console untuk error.

#### 2. SplashScreen Freeze
`home: const SplashScreen()` bisa tidak redirect.

**Quick test:**
```dart
// Temporary change main.dart
home: const MainScreen(userRole: 'warga'),
// Bypass SplashScreen
```

Jika langsung muncul, berarti masalah di SplashScreen navigation.

## Recommended Development Workflow

### For Development:
```bash
# Terminal 1: Run web server
flutter run -d web-server --web-port 8080

# Browser: Manual open
http://localhost:8080
```

### For Testing:
```bash
# Build release untuk testing production
flutter build web --release --web-renderer html
cd build/web
python -m http.server 8080
```

### For Mobile Testing:
```bash
# Run di Android Emulator (lebih stable)
flutter run

# Atau di physical device
flutter run -d <device-id>
```

---

## TL;DR Quick Commands

```bash
# Clean everything
flutter clean
taskkill /F /IM chrome.exe

# Run dengan fixed port
flutter run -d chrome --web-hostname localhost --web-port 8080 --web-renderer html

# Di app:
# Press R (capital) untuk Hot Restart
# Jangan press r (lowercase) untuk Hot Reload

# Jika masih bermasalah:
# Build dan serve manual
flutter build web
cd build/web
python -m http.server 8080
# Open: http://localhost:8080
```
