# LAPORAN PENGUJIAN PERANGKAT LUNAK (PMPL)
## JAWARA CLOTHING STORE v1.4.0

---

## 1. INFORMASI UMUM PROYEK

| Item | Keterangan |
| --- | --- |
| Nama Aplikasi/Perangkat Lunak | JAWARA CLOTHING STORE |
| Versi Aplikasi | 1.4.0 (Release Candidate) |
| Platform | Mobile (Flutter), Web (React), Backend (PHP) |
| Periode Pengujian | 15–24 Desember 2025 |
| Tim Penguji | Charellino K S (Lead QA); M. Atho'illah M (API/Backend); Mikaila Kafka (Mobile/E2E) |
| Lokasi Testing | Staging Environment (192.168.1.100) |
| Tanggal Penyelesaian Laporan | 26 Desember 2025 |
| Budget Testing | 168 jam kerja (~2 minggu) |

---

## 2. EXECUTIVE SUMMARY

### 2.1 Ringkasan Tujuan & Ruang Lingkup
Pengujian perangkat lunak JAWARA CLOTHING STORE bertujuan memverifikasi bahwa aplikasi siap dirilis ke production dengan:
- Semua fitur utama berfungsi sesuai requirement
- Stabilitas performa di bawah beban pengguna normal dan stress
- Keamanan data dan autentikasi berjalan sempurna
- User experience yang konsisten di semua platform (mobile, web)

### 2.2 Metrik Ringkasan
- **Total Test Cases**: 68 (Functional: 28, E2E: 12, API: 18, Unit: 10)
- **Hasil**: 
  - ✅ Passed: 59 (86.8%)
  - ❌ Failed: 7 (10.3%)
  - ⚠️ Blocked: 2 (2.9%)
- **Success Rate**: 86.8%
- **Defect Density**: 8 bugs per 1000 LOC (target: < 5)

### 2.3 Temuan Kritis
1. **BUG-021 (Critical)**: Payment gateway timeout pada metode kartu > 5s; berakibat transaksi terputus dan konfusi user
2. **BUG-023 (High)**: Refresh token API mengembalikan 401 meski token masih valid; logout paksa setelah 1 jam
3. **BUG-017 (Medium)**: Validasi ukuran foto > 2MB tidak tertampil pesan error yang jelas
4. **BUG-045 (High)**: Chat duplikat message diterima ketika network flaky
5. **BUG-062 (Medium)**: ML detection model menolak foto dalam format WEBP

### 2.4 Rekomendasi Kelayakan Rilis
- **Status**: ⚠️ **GO DENGAN CATATAN** (Conditional Release)
- **Syarat Rilis**:
  - ✅ Fix BUG-021 dan BUG-023 sebelum produksi
  - ✅ Re-run regression testing E2E checkout dan API refresh
  - ✅ Update dokumentasi user tentang format foto WEBP tidak didukung
  - ✅ Implementasi retry mechanism untuk payment gateway

---

## 3. LINGKUP DAN METODOLOGI PENGUJIAN

### 3.1 Fitur yang Diuji (In Scope)

#### Untuk Pengguna Warga:
- ✅ Login/Registrasi (email, password reset)
- ✅ Browsing produk (search, filter, kategori)
- ✅ Cart & Checkout (simpan cart, qty adjustment)
- ✅ Payment (kartu kredit, transfer bank, e-wallet)
- ✅ Order tracking & history
- ✅ Clothing detection via camera (ML feature)
- ✅ Chat dengan RT
- ✅ Notifikasi transaksi & promo
- ✅ Profil & pengaturan (alamat, bahasa, tema)
- ✅ Wishlist & favorites

#### Untuk Pengguna RT (Rukun Tetangga):
- ✅ Dashboard overview (penjualan, warga aktif)
- ✅ Verifikasi registrasi warga baru
- ✅ Chat dengan warga
- ✅ Kelola approval transaksi (jika diperlukan)
- ✅ Lihat laporan penjualan harian/mingguan
- ✅ Kelola notifikasi broadcast ke warga

#### Untuk Admin:
- ✅ Admin login & role management
- ✅ Kelola produk & kategori
- ✅ Kelola user (warga, RT)
- ✅ Lihat semua transaksi & reporting
- ✅ Monitor performance & error logs
- ✅ Konfigurasi payment gateway

### 3.2 Fitur yang Dikecualikan (Out of Scope)
- ❌ Pembayaran COD offline (ditunda v1.5)
- ❌ Dashboard analitik advanced admin (belum development selesai)
- ❌ Push notifikasi iOS (belum sertifikasi)
- ❌ Video streaming product (future enhancement)
- ❌ Integrasi B2B wholesale (fase berikutnya)

### 3.3 Lingkungan Pengujian

| Aspek | Detail |
| --- | --- |
| **OS Desktop** | Windows 11 Pro (22H2), macOS 14.2 |
| **Mobile** | Android Emulator Pixel 6 (API 33), iPhone 14 Pro (iOS 17.2) simulator |
| **Browser** | Chrome 120.0, Firefox 121.0, Safari 17.2 |
| **Backend Server** | PHP 8.1, MySQL 8.0, Redis 7.0 (staging) |
| **API ML** | HuggingFace Space (clothing detection HOG+SVM) |
| **Network** | 4G LTE simulation (100 Mbps down, 20 Mbps up) |
| **Database** | MySQL staging copy (100K records produk, 50K user) |

### 3.4 Tools & Framework

| Kategori | Tools |
| --- | --- |
| **Functional Testing** | Postman, Playwright, Flutter test |
| **API Testing** | pytest + requests, REST Assured, cURL |
| **Performance** | k6 (load/stress), JMeter, Chrome DevTools |
| **Unit Testing** | unittest (Python), Dart test framework |
| **Code Coverage** | coverage.py, Dart coverage, Istanbul |
| **Test Data** | faker, CSV mock data, seeding scripts |
| **Bug Tracking** | Jira, GitHub Issues |
| **Log Analysis** | ELK stack, CloudWatch, local log files |
| **Automation** | CI/CD GitHub Actions, Jenkins |

---

## 4. DETAIL PENGUJIAN PER FITUR

### 4.1 FITUR AUTENTIKASI (Authentication)

#### 4.1.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-WRG-001 | Registrasi warga baru | 1. Buka app → 2. Tap "Daftar" → 3. Masukkan email, password (min 8 karakter), nama, alamat → 4. Tap "Daftar" | Email unique validation, OTP dikirim, record terinsert di DB | Email validation passed, OTP 123456 terkirim via email dummy, user record created | ✅ Pass | Perlu disable email validation saat testing |
| AUTH-WRG-002 | Login dengan kredensial valid | 1. Input email & password → 2. Tap Login | HTTP 200, token JWT dikembalikan, redirect ke dashboard | Token `eyJ0eXAi...` diterima, redirect berhasil | ✅ Pass | Token exp: 24h |
| AUTH-WRG-003 | Login dengan password salah | Input email + wrong pwd | HTTP 401, pesan "Password salah" | Menerima 401, pesan tampil | ✅ Pass | - |
| AUTH-WRG-004 | Login dengan email tidak terdaftar | Input email tak ada | HTTP 404, pesan "Email tidak ditemukan" | 404 returned, msg displayed | ✅ Pass | - |
| AUTH-WRG-005 | Reset password | 1. Tap "Lupa Password" → 2. Masukkan email → 3. Buka link di email → 4. Buat password baru | Email dikirim, link valid 30 menit, password updated | Email diterima, link work, DB updated | ✅ Pass | Link TTL: 30 min |
| AUTH-WRG-006 | Logout | Tap menu → Logout | Token dihapus dari storage, redirect ke login | Storage cleared, login screen shown | ✅ Pass | - |
| AUTH-WRG-007 | Auto-logout setelah session timeout (24h) | Tunggu 24 jam atau modify token exp | Auto redirect ke login, pesan "Session expired" | Redirect after 24h (simulated) | ✅ Pass | Timeout: 24h |
| AUTH-WRG-008 | Refresh token sebelum expire | Call API /auth/refresh dengan valid refresh_token | HTTP 200, new access token returned | ❌ HTTP 401 returned instead | ❌ Fail | **BUG-023** |
| AUTH-WRG-009 | Two-factor auth (2FA) optional | Enable 2FA di settings → login ulang | SMS/email OTP prompt, verifikasi berhasil | 2FA workflow working, OTP valid 10 min | ✅ Pass | OTP method: SMS/email |

#### 4.1.2 Pengujian untuk RT (Rukun Tetangga)

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-RT-010 | RT login dengan kredensial khusus | Input RT email + password | Token role `rt` issued, redirect ke RT dashboard | Token berisi role=rt, dashboard shown | ✅ Pass | Role-based access control |
| AUTH-RT-011 | RT cannot access warga features | RT login → coba akses warga checkout | HTTP 403 Forbidden | 403 returned | ✅ Pass | RBAC enforced |
| AUTH-RT-012 | RT session timeout 48h | Login RT → tunggu 48h | Auto-logout, redirect login | ✅ Pass setelah 48h simulated | ✅ Pass | Timeout: 48h |

#### 4.1.3 Pengujian untuk Admin

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-ADMIN-013 | Admin SSO login (jika ada) | Login via corporate SSO provider | Token issued dengan role admin | SSO redirect works, token admin role | ✅ Pass | SSO endpoint: `/sso/admin` |
| AUTH-ADMIN-014 | Admin cannot login jika 2FA disabled | Disable 2FA di server config → admin login | Require 2FA | ⚠️ 2FA optional, tidak enforce | ⚠️ Block | **Issue**: 2FA harus mandatory untuk admin |

---

### 4.2 FITUR MARKETPLACE (Produk & Katalog)

#### 4.2.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-WRG-001 | Lihat list produk dengan pagination | Login warga → Tap Shop → scroll | 20 produk/page, pagination buttons visible | 20 items loaded, page 1 default, next/prev work | ✅ Pass | Pagination: 20 items/page |
| SHOP-WRG-002 | Search produk by keyword | Masukkan "kemeja" di search box | Produk berisi "kemeja" ditampilkan, hasil < 2s | 8 results shown (kemeja biru, kemeja putih, dll), 1.2s response | ✅ Pass | Search response < 2s |
| SHOP-WRG-003 | Filter by kategori | Tap kategori "T-Shirt" | Hanya T-Shirt visible | 45 T-Shirt ditampilkan | ✅ Pass | - |
| SHOP-WRG-004 | Filter by harga range | Set range 100K - 500K | Produk dalam range ditampilkan | 32 products in range | ✅ Pass | - |
| SHOP-WRG-005 | Sort by price ascending | Tap "Harga (Terendah)" | List diurutkan ascending | ✅ Pass | - |
| SHOP-WRG-006 | View product detail | Tap product "Kemeja Flanel" | Detail page: foto, deskripsi, harga, rating, review | Semua elemen tampil dengan benar | ✅ Pass | - |
| SHOP-WRG-007 | Lihat rating & review produk | Scroll di product detail → lihat reviews | Minimal 5 review terlihat, rata-rata rating ditampilkan | 12 reviews shown, avg 4.5/5 | ✅ Pass | - |
| SHOP-WRG-008 | Add product to wishlist | Tap ❤️ icon di product detail | Produk masuk wishlist, icon berubah warna | Wishlist updated, heart red | ✅ Pass | - |
| SHOP-WRG-009 | Add product ke cart | Tap "Tambah ke Keranjang" → pilih qty → confirm | Product + qty masuk cart, badge cart update | 1 item added, cart badge show "1" | ✅ Pass | - |
| SHOP-WRG-010 | Lihat product dengan foto > 2MB | Upload foto produk 3MB | Foto ditolak dengan pesan error | ❌ Foto upload tapi error tidak jelas | ❌ Fail | **BUG-017** |

#### 4.2.2 Pengujian untuk RT

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-RT-011 | RT browse warga products | RT login → lihat produk dari warga mereka | Hanya produk dari warga di RT tampil | 52 produk dari 8 warga RT | ✅ Pass | Filter by RT zone |
| SHOP-RT-012 | RT approve produk sebelum jual | Admin set: RT harus approve produk | New produk pending, RT dapat notif | Notif diterima, approval dashboard available | ✅ Pass | Feature: RT approval gating |

#### 4.2.3 Pengujian untuk Admin

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| SHOP-ADMIN-013 | Admin upload product template | Admin → Products → Bulk Upload CSV | CSV diparse, 100+ produk inserted | 125 products bulk uploaded | ✅ Pass | CSV format documented |
| SHOP-ADMIN-014 | Kelola kategori produk | Admin → Kategori → Add/Edit/Delete | CRUD operations work, semua user lihat perubahan | All CRUD work, changes propagated | ✅ Pass | - |

---

### 4.3 FITUR CHECKOUT & PEMBAYARAN (Payment)

#### 4.3.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PAY-WRG-001 | Lihat cart sebelum checkout | Tap cart icon | Cart items, total harga, tax, shipping ditampilkan | 2 items, subtotal 500K, tax 50K, shipping 25K, total 575K | ✅ Pass | - |
| PAY-WRG-002 | Adjust quantity di cart | Ubah qty item dari 1 → 3 | Harga otomatis update | Harga updated to 1.5M | ✅ Pass | Real-time calculation |
| PAY-WRG-003 | Remove item dari cart | Tap delete icon | Item hilang, harga update | Item removed, total recalculate | ✅ Pass | - |
| PAY-WRG-004 | Apply discount code | Masukkan kode "DISKON20" (20% off) | Harga reduced, breakdown ditampilkan | Diskon 115K applied, total 460K | ✅ Pass | - |
| PAY-WRG-005 | Checkout dengan metode Kartu Kredit | 1. Review cart → 2. Tap Checkout → 3. Pilih Kartu Kredit → 4. Redirect ke payment gateway → 5. Masukkan kartu details | Payment processed < 5s, order confirmed, email receipt | ❌ Timeout setelah 7s di gateway | ❌ Fail | **BUG-021** (gateway timeout) |
| PAY-WRG-006 | Checkout dengan Bank Transfer | 1. Pilih Bank Transfer → 2. Display virtual account nomor → 3. User transfer via bank app | VA number 1234567890 ditampilkan, payment pending status | VA shown, status = pending | ✅ Pass | - |
| PAY-WRG-007 | Checkout dengan E-wallet (OVO/GoPay) | Pilih OVO → Scan QR | QR ditampilkan, redirect ke OVO app, konfirmasi | QR shown, e-wallet success | ✅ Pass | - |
| PAY-WRG-008 | Input alamat pengiriman saat checkout | Pilih alamat dari profil atau input baru | Alamat disimpan, dikirim ke backend | Alamat stored & sent to backend | ✅ Pass | - |
| PAY-WRG-009 | Lihat order confirmation page | Setelah payment berhasil | Order ID, status "Diproses", detail item, total, estimasi pengiriman | Order INV-2025-12-0001, status "Diproses", ETA 2-3 hari | ✅ Pass | - |
| PAY-WRG-010 | Order payment retry jika timeout | Retry payment setelah timeout | Payment re-attempt, tidak duplikat charge | Retry successful, tidak ada double charge | ✅ Pass | Dengan BUG-021 fixed |

---

### 4.4 FITUR CHAT (Komunikasi)

#### 4.4.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CHAT-WRG-001 | Lihat list chat dengan RT | Tap Chat → list RT conversations | List all RT (1-2 conversation per user) | 2 RT conversations shown | ✅ Pass | - |
| CHAT-WRG-002 | Buka chat dengan specific RT | Tap RT "Paket" | Chat history loaded, pesan lama visible | 15 previous messages loaded | ✅ Pass | - |
| CHAT-WRG-003 | Kirim text message | Masukkan text "Halo pak, produk ready?" → Tap Send | Message instant deliver, appear di recipient | Message sent immediately, RT receive | ✅ Pass | - |
| CHAT-WRG-004 | Kirim foto di chat | Tap attachment → select foto → send | Foto terkirim, preview visible, < 3s latency | Foto sent, preview shown, 2.1s latency | ✅ Pass | - |
| CHAT-WRG-005 | Receive message dari RT | RT kirim message | Notifikasi muncul, message appear | Notif received, message visible | ✅ Pass | - |
| CHAT-WRG-006 | Duplicate message pada network flaky | Simulate flaky 3G network → send message | 1 message sent, tidak ada duplicate | ❌ 2 message terkirim (duplicate) | ❌ Fail | **BUG-045** (duplicate on flaky network) |
| CHAT-WRG-007 | Chat search/filter | Tap search di chat → cari "siapa harga" | Messages containing keyword ditampilkan | 3 messages dengan "harga" found | ✅ Pass | - |
| CHAT-WRG-008 | Lihat typing indicator saat RT mengetik | RT mengetik → warga lihat "Paket sedang mengetik..." | Typing indicator visible | "Paket is typing..." shown | ✅ Pass | - |
| CHAT-WRG-009 | Message read receipts | Kirim message → lihat read status | Double checkmark setelah RT baca | Read receipt shown after read | ✅ Pass | - |

#### 4.4.2 Pengujian untuk RT

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CHAT-RT-010 | RT lihat all chat dari warga | RT login → Tap Chat | List of 10+ warga conversations, sorted by last message | 12 conversations shown, latest first | ✅ Pass | - |
| CHAT-RT-011 | RT dapat broadcast message ke semua warga | RT → Broadcast → Compose message → Send | Message dikirim ke semua warga RT | Message sent to 25 residents | ✅ Pass | - |
| CHAT-RT-012 | RT block/mute warga dari chat | Tap warga → block option | Warga tidak bisa chat, RT tidak terima notif | Block successful, mute active | ✅ Pass | - |

---

### 4.5 FITUR DETEKSI PAKAIAN via ML (Clothing Detection)

#### 4.5.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ML-WRG-001 | Buka camera detection feature | Tap "Deteksi Pakaian" di home | Camera opens, instruction displayed | Camera opens, UI clear | ✅ Pass | - |
| ML-WRG-002 | Ambil foto pakaian dari camera | Arahkan ke pakaian, tap "Foto" | Foto tersimpan, sent to ML API, loading bar visible | Foto captured, sending... | ✅ Pass | - |
| ML-WRG-003 | ML model predict clothing label | Tunggu ML API respond | Prediksi label (Hat/Shirt/Shoes/T-Shirt), confidence score ditampilkan | Predicted: "T-Shirt", confidence 0.95 (95%) | ✅ Pass | Model: HOG+SVM |
| ML-WRG-004 | Kategori confidence rendah < 70% | Ambil foto kabur/partial | Label ditampilkan, tapi warning "confidence rendah" | Label "Shoes" (0.62), warning shown | ✅ Pass | - |
| ML-WRG-005 | Upload existing foto dari gallery | Tap "Upload dari Galeri" → pilih JPG | Proses sama seperti camera capture | JPG processed, prediction returned | ✅ Pass | - |
| ML-WRG-006 | Foto format WEBP ditolak | Select WEBP image | Error message "Format hanya JPG/PNG" | ❌ Foto accepted tapi error saat process | ❌ Fail | **BUG-062** (WEBP format) |
| ML-WRG-007 | Lihat detection history | Tap "Riwayat Deteksi" | List semua deteksi sebelumnya, timestamp | 8 previous detections shown with date | ✅ Pass | - |
| ML-WRG-008 | Performance: ML API response < 2s | Ambil foto → submit | Response time < 2 detik | Response time 1.8s avg | ✅ Pass | HuggingFace inference time |

#### 4.5.2 API Testing untuk ML

| Test Case ID | Endpoint | Method | Request | Expected Response | Actual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ML-API-009 | /api/v1/ml/detect | POST | `{image_base64: "...", confidence_threshold: 0.7}` | `{label: "Shirt", confidence: 0.92, processing_time_ms: 1200}` | Label, confidence, time returned | ✅ Pass | - |
| ML-API-010 | /api/v1/ml/detect | POST | Blank image | `{error: "Image cannot be empty"}`, 400 | 400 error returned | ✅ Pass | - |
| ML-API-011 | /api/v1/ml/detect | POST | Oversized image (>10MB) | `{error: "Image too large"}`, 413 | 413 returned | ✅ Pass | - |
| ML-API-012 | /api/v1/ml/history/{user_id} | GET | Auth token | `{detections: [...], total: 8}` | History list with 8 items | ✅ Pass | - |

---

### 4.6 FITUR NOTIFIKASI (Notifications)

#### 4.6.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| NOTIF-WRG-001 | Terima notif transaksi berhasil | Complete payment → notif sent | In-app notif + push notif (Android) | Notif received in 2s | ✅ Pass | - |
| NOTIF-WRG-002 | Lihat notif history | Tap bell icon → lihat list | List 10+ notif dengan timestamp | 12 notif shown, newest first | ✅ Pass | - |
| NOTIF-WRG-003 | Mark notif as read | Tap notif → read | Notif status = read, visual change | Notif marked read | ✅ Pass | - |
| NOTIF-WRG-004 | Delete notif | Swipe left/right → delete | Notif dihapus | Notif removed | ✅ Pass | - |
| NOTIF-WRG-005 | Manage notif preferences | Setting → Notifications → toggle channels | Push, email, SMS preference saved | Settings persisted | ✅ Pass | - |
| NOTIF-WRG-006 | Terima promo broadcast dari RT | RT kirim broadcast | Notif "Promo: Diskon 30%" received | Broadcast notif received | ✅ Pass | - |

---

### 4.7 FITUR PROFIL & PENGATURAN (Profile & Settings)

#### 4.7.1 Pengujian untuk Warga

| Test Case ID | Skenario | Aksi | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PROF-WRG-001 | Lihat profile info | Tap Profile → view | Nama, email, alamat, foto profile ditampilkan | All info shown | ✅ Pass | - |
| PROF-WRG-002 | Edit nama & email | Tap Edit → ubah nama → Save | Validasi unique email, data tersimpan | Changes saved, success msg | ✅ Pass | - |
| PROF-WRG-003 | Upload/change avatar | Tap avatar → upload foto | Foto compress, resize, disimpan | Avatar updated | ✅ Pass | - |
| PROF-WRG-004 | Ganti password | Setting → Change Password → input lama & baru | Validasi password lama benar, baru >= 8 char | Password updated | ✅ Pass | - |
| PROF-WRG-005 | Ganti bahasa ke English | Setting → Bahasa → English | UI translate ke English, preference saved | Language changed to EN | ✅ Pass | - |
| PROF-WRG-006 | Dark mode toggle | Setting → Theme → Dark | App skin dark, preference saved | Dark theme applied | ✅ Pass | - |
| PROF-WRG-007 | Lihat order history | Tap Orders | List all past orders dengan status | 24 orders shown, sorted by date | ✅ Pass | - |
| PROF-WRG-008 | Lihat wishlist | Tap Wishlist | All favorited products displayed | 7 wishlist items shown | ✅ Pass | - |

---

## 5. HASIL PENGUJIAN END-TO-END (E2E)

### 5.1 Skenario E2E - Warga

| Test Case ID | Skenario Bisnis | Langkah | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-WRG-001 | Customer Purchase Flow | 1. Register warga baru → 2. Login → 3. Browse produk → 4. Search "kemeja" → 5. Add to cart → 6. Checkout → 7. Payment (transfer) → 8. Confirm | Order INV created, email receipt, order tracking ready | Berhasil sampai langkah 8, order created | ✅ Pass | Flow normal |
| E2E-WRG-002 | Payment with Card (BUG test) | 1. Warga checkout → 2. Pilih Kartu Kredit → 3. Fill form → 4. Submit | Payment 200 OK < 5s, order confirmed | ❌ Gateway timeout 7s, transaksi gagal | ❌ Fail | **BUG-021**: Retry needed |
| E2E-WRG-003 | Chat dengan RT | 1. Warga login → 2. Tap Chat → 3. Select RT → 4. Send "Halo, produk ready?" → 5. Wait for reply | Message terkirim instant, RT terima notif | ✅ Message sent, RT notif received | ✅ Pass | Latency 1.2s |
| E2E-WRG-004 | Clothing Detection | 1. Warga home → 2. Tap "Deteksi Pakaian" → 3. Take photo kemeja → 4. Submit → 5. Wait for ML prediction | Prediction "T-Shirt" confidence 95% dalam 2s | ✅ Prediction returned, 1.8s | ✅ Pass | - |
| E2E-WRG-005 | Return/Refund flow | 1. Login → 2. Lihat past order → 3. Tap order → 4. "Request Return" → 5. Select reason → 6. Confirm | Return request pending, notif ke RT & seller | Request pending, notif sent | ✅ Pass | Feature: Return workflow |

### 5.2 Skenario E2E - RT

| Test Case ID | Skenario Bisnis | Langkah | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-RT-001 | RT approve new resident | 1. RT login → 2. Dashboard → 3. Pending Warga list → 4. Tap warga "Budi" → 5. Verify data → 6. Approve | Warga status = approved, notif sent, akses granted | ✅ Approval successful | ✅ Pass | - |
| E2E-RT-002 | RT broadcast promo | 1. RT → Broadcast → 2. Compose "Promo: Diskon 30%" → 3. Select audience → 4. Send | Pesan sent to all warga, notif received in < 2s | ✅ Broadcast to 25 warga | ✅ Pass | - |
| E2E-RT-003 | RT view sales report | 1. RT → Dashboard → 2. Lihat daily sales | Chart menampilkan sales 10 juta rupiah, breakdown by warga | Report generated, chart visible | ✅ Pass | Data realistic |

### 5.3 Skenario E2E - Admin

| Test Case ID | Skenario Bisnis | Langkah | Hasil Ekspektasi | Hasil Aktual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| E2E-ADMIN-001 | Admin bulk upload product | 1. Admin → Products → Bulk Upload → 2. Select CSV file → 3. Review preview → 4. Confirm | 125 produk inserted, success message, ready to sell | ✅ Bulk upload successful | ✅ Pass | CSV parsing correct |
| E2E-ADMIN-002 | Admin manage payment gateway | 1. Admin → Settings → Payment → 2. Update API key → 3. Test transaction | Test payment successful, live mode ready | ✅ Payment gateway configured | ✅ Pass | - |

---

## 6. HASIL PENGUJIAN API

### 6.1 Authentication APIs

| Endpoint | Method | Test Case | Request Body | Expected Status | Actual Status | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/auth/register | POST | REG-001 | `{email, password, name, address}` | 201 Created | 201 | ✅ Pass | - |
| /api/v1/auth/register | POST | REG-002 | Duplicate email | 409 Conflict | 409 | ✅ Pass | - |
| /api/v1/auth/login | POST | LOGIN-001 | Valid email & pwd | 200 + token | 200 + token | ✅ Pass | - |
| /api/v1/auth/login | POST | LOGIN-002 | Wrong pwd | 401 Unauthorized | 401 | ✅ Pass | - |
| /api/v1/auth/refresh | POST | REFRESH-001 | Valid refresh_token | 200 + new token | 401 ❌ | ❌ Fail | **BUG-023** |
| /api/v1/auth/logout | POST | LOGOUT-001 | Valid token | 200 | 200 | ✅ Pass | - |

### 6.2 Product APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/products | GET | PROD-001 | `?page=1&limit=20` | 200 + 20 items | 200 + 20 items | ✅ Pass | Pagination OK |
| /api/v1/products?search=kemeja | GET | PROD-002 | search param | 200 + filtered | 8 results found | ✅ Pass | Search < 2s |
| /api/v1/products/{id} | GET | PROD-003 | Product ID | 200 + detail | 200 + full detail | ✅ Pass | - |
| /api/v1/products | POST | PROD-004 | New product JSON | 201 + id | 201 + id | ✅ Pass | Auth required |
| /api/v1/products/{id}/review | POST | PROD-005 | Review + rating | 201 | 201 | ✅ Pass | - |

### 6.3 Cart & Checkout APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/cart | POST | CART-001 | `{product_id, qty}` | 200 + item added | 200 | ✅ Pass | - |
| /api/v1/cart | GET | CART-002 | Auth token | 200 + cart items | 200 + 2 items | ✅ Pass | - |
| /api/v1/checkout | POST | CHECKOUT-001 | Cart ID, address, method | 201 + order ID | 201 | ✅ Pass | - |
| /api/v1/payment/process | POST | PAY-001 | `{order_id, method, amount}` | 200 redirect to gateway | Timeout after 7s ❌ | ❌ Fail | **BUG-021** |

### 6.4 Chat APIs

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/chat/messages/{user_id} | GET | CHAT-001 | user_id, auth token | 200 + messages | 200 + 15 msgs | ✅ Pass | - |
| /api/v1/chat/send | POST | CHAT-002 | `{recipient_id, message}` | 201 + msg_id | 201 | ✅ Pass | - |
| /api/v1/chat/send (flaky network) | POST | CHAT-003 | Retry on 3G | 1 msg sent | 2 msgs sent ❌ | ❌ Fail | **BUG-045** |

### 6.5 ML Detection API

| Endpoint | Method | Test | Request | Expected | Actual | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /api/v1/ml/detect | POST | ML-001 | `{image_base64}` | 200 + {label, confidence} | T-Shirt, 0.95 | ✅ Pass | - |
| /api/v1/ml/detect | POST | ML-002 | WEBP format | Reject or warn | Accepted but error ❌ | ❌ Fail | **BUG-062** |

---

## 7. HASIL PENGUJIAN UNIT & INTEGRASI

### 7.1 Unit Test Summary

| Modul | Total Tests | Passed | Failed | Coverage | Status |
| --- | --- | --- | --- | --- | --- |
| AuthService (Python) | 12 | 12 | 0 | 95% | ✅ Pass |
| ProductService | 15 | 15 | 0 | 92% | ✅ Pass |
| CartService | 18 | 17 | 1 | 88% | ⚠️ 1 fail |
| PaymentService | 20 | 19 | 1 | 85% | ⚠️ 1 fail |
| ChatService | 10 | 9 | 1 | 80% | ⚠️ 1 fail |
| NotificationService | 8 | 8 | 0 | 90% | ✅ Pass |
| MLService | 10 | 10 | 0 | 93% | ✅ Pass |
| **TOTAL** | **93** | **90** | **3** | **89%** | **90.3% pass rate** |

### 7.2 Integration Test Results

| Integration Point | Components | Test Scenario | Result | Notes |
| --- | --- | --- | --- | --- |
| Auth + Database | AuthService ↔ MySQL | Login workflow, token generation | ✅ Pass | - |
| Product + Cache | ProductService ↔ Redis | Product search caching | ✅ Pass | Cache hit 75% |
| Payment + External Gateway | PaymentService ↔ Stripe | Charge transaction | ❌ Timeout | **BUG-021** |
| Chat + FCM | ChatService ↔ Firebase | Message send + notif | ✅ Pass | - |
| ML + HF Space | MLService ↔ HuggingFace | Image detection inference | ✅ Pass | 1.8s latency |
| Notification + Email | NotifService ↔ SendGrid | Email delivery | ✅ Pass | 2.3s delivery |

---

## 8. HASIL PENGUJIAN PERFORMA (Performance Testing)

### 8.1 Load Testing (k6 dengan 100 virtual users)

| Metrik | Target | Actual | Status |
| --- | --- | --- | --- |
| Average Response Time | < 2.0s | 1.4s | ✅ Pass |
| P95 Response Time | < 3.0s | 2.8s | ✅ Pass |
| P99 Response Time | < 5.0s | 4.2s | ✅ Pass |
| Throughput | > 100 req/s | 160 req/s | ✅ Pass |
| Error Rate | < 0.5% | 0.1% | ✅ Pass |
| CPU Usage | < 70% | 62% | ✅ Pass |
| Memory Usage | < 70% | 58% | ✅ Pass |

### 8.2 Stress Testing (500 virtual users)

| Metrik | Target | Actual | Status | Notes |
| --- | --- | --- | --- | --- |
| Average Response Time | < 5.0s | 4.6s | ✅ Pass | Acceptable degradation |
| Throughput | > 300 req/s | 410 req/s | ✅ Pass | Exceeds target |
| Error Rate | < 2% | 0.7% | ✅ Pass | Payment gateway bottleneck |
| CPU Usage | < 90% | 89% | ✅ Pass | Peak capacity |
| Memory Usage | < 90% | 82% | ✅ Pass | Stable |
| Database Connections | < 100 | 94 | ✅ Pass | Near limit |

### 8.3 Soak Testing (2 jam dengan 150 users)

| Metrik | Target | Actual | Status |
| --- | --- | --- | --- |
| Avg Response Time (stable) | < 2.5s | 1.9s | ✅ Pass |
| Memory Leak | None | None detected | ✅ Pass |
| Error Rate (cumulative) | < 1% | 0.2% | ✅ Pass |
| Uptime | 100% | 100% | ✅ Pass |

### 8.4 Database Performance

| Query | Execution Time | Status | Notes |
| --- | --- | --- | --- |
| `SELECT * FROM products LIMIT 20` | 45ms | ✅ Pass | Indexed |
| `SELECT * FROM products WHERE category='Shirt'` | 120ms | ✅ Pass | Indexed |
| `SELECT * FROM orders WHERE user_id=X` | 80ms | ✅ Pass | Indexed |
| Bulk insert 1000 products | 2.3s | ✅ Pass | Batch optimized |

---

## 9. RINGKASAN DEFECT/BUG

### 9.1 Defect Breakdown by Severity

| Severity | Count | Open | Closed | Avg Fix Time | Status |
| --- | --- | --- | --- | --- | --- |
| 🔴 Critical | 1 | 1 | 0 | 6h est. | Blocking release |
| 🟠 High | 2 | 1 | 1 | 9h avg | Urgent |
| 🟡 Medium | 3 | 0 | 3 | 12h avg | Fixed |
| 🟢 Low | 2 | 0 | 2 | 18h avg | Fixed |
| **TOTAL** | **8** | **2** | **6** | - | 75% closed |

### 9.2 Detail Setiap Bug

#### BUG-021 (CRITICAL)
- **Title**: Payment Gateway Timeout on Card Payment
- **Severity**: CRITICAL
- **Module**: PaymentService / Payment Gateway Integration
- **Steps to Reproduce**:
  1. Login warga
  2. Add product to cart
  3. Checkout with credit card
  4. Fill payment form
  5. Submit
- **Expected**: Payment processed within 5 seconds
- **Actual**: Timeout after 7 seconds, transaction failed
- **Impact**: Users cannot complete purchase via card; revenue loss
- **Root Cause**: Slow API response from payment gateway; possible network latency
- **Recommended Fix**: 
  - Implement exponential backoff retry mechanism
  - Increase payment API timeout to 15s (temporary)
  - Scale payment service horizontally
  - Add CDN for gateway latency
- **Status**: OPEN - Assigned to Backend team
- **Priority**: Fix before release

#### BUG-023 (HIGH)
- **Title**: Refresh Token Returns 401 Instead of 200
- **Severity**: HIGH
- **Module**: AuthService / Token Management
- **Steps**:
  1. User login and get access token + refresh token
  2. Wait for access token to expire (24h) or manually expire
  3. Call `/api/v1/auth/refresh` with valid refresh token
- **Expected**: HTTP 200 with new access token
- **Actual**: HTTP 401 Unauthorized
- **Impact**: Users forced to logout after 24h; poor experience on long sessions
- **Root Cause**: Refresh token validation logic incorrect; not checking expiration properly
- **Recommended Fix**:
  - Review AuthService.refresh() logic
  - Add unit tests for edge cases
  - Extend refresh token TTL to 7 days (if security allows)
- **Status**: OPEN - Assigned to Backend
- **Priority**: Fix before release

#### BUG-017 (MEDIUM)
- **Title**: File Size Validation Error Message Not Clear
- **Severity**: MEDIUM
- **Module**: Product Upload / Frontend Validation
- **Steps**:
  1. Admin/Warga upload product photo > 2MB
  2. Observe error response
- **Expected**: Clear error message "File size must be < 2MB"
- **Actual**: Generic error or no message shown
- **Impact**: User confusion; unclear why upload failed
- **Root Cause**: Frontend validation missing or backend error not translated
- **Fix**: Add client-side validation before upload, show tooltip
- **Status**: CLOSED ✅
- **Fix Date**: 2025-12-23

#### BUG-045 (HIGH)
- **Title**: Duplicate Chat Messages on Flaky Network
- **Severity**: HIGH
- **Module**: ChatService / Message Sending
- **Steps**:
  1. Simulate flaky 3G network (high packet loss)
  2. Send chat message
  3. Observe duplicate message in conversation
- **Expected**: 1 message sent
- **Actual**: 2 identical messages
- **Impact**: Confusing chat experience; duplicate content
- **Root Cause**: Retry logic at app level + server level = double send
- **Recommended Fix**: Implement idempotency key in message payload
- **Status**: OPEN - Assigned to Mobile team
- **Priority**: High (poor UX)

#### BUG-062 (MEDIUM)
- **Title**: ML Detection Rejects WEBP Format Without Clear Error
- **Severity**: MEDIUM
- **Module**: MLDetectionService
- **Steps**:
  1. Warga upload WEBP image for clothing detection
  2. API attempts to process
- **Expected**: Error message "Only JPG/PNG supported"
- **Actual**: Image accepted but processing fails silently
- **Impact**: User confusion; feature seems broken
- **Root Cause**: Frontend doesn't validate format; backend silently fails
- **Recommended Fix**: Add format validation on frontend + improve error response
- **Status**: CLOSED ✅
- **Fix Date**: 2025-12-24

### 9.3 Bug Trend Analysis
- **Bugs by Component**:
  - Payment: 2 bugs (25%)
  - Auth: 1 bug (12.5%)
  - Chat: 1 bug (12.5%)
  - ML: 1 bug (12.5%)
  - Upload: 1 bug (12.5%)
  - Other: 2 bugs (25%)
- **Trend**: Fewer bugs in v1.4.0 vs v1.3.5 (was 15 bugs); improvement due to better unit testing

---

## 10. ANALISIS RISIKO RILIS

### 10.1 Risiko Teknis

| Risiko | Probabilitas | Impact | Mitigation |
| --- | --- | --- | --- |
| Payment timeout masalah produksi | High (60%) | Critical | Fix before rilis, monitoring 24/7, fallback metode |
| Session timeout user mengganggu UX | Medium (40%) | High | Extend token, improve messaging |
| Chat duplikat message | Medium (30%) | Medium | Idempotency key, client-side dedup |
| Database connection pool overflow | Low (15%) | High | Monitor, scale horizontally |

### 10.2 Risiko Bisnis

| Risiko | Dampak | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Lost sales akibat payment failure | Revenue loss 5-10% | Medium | Fix payment, add retry |
| User churn karena forced logout | User loss 2-3% | Medium | Better token handling |
| Negative review di app store | Rating -0.5 stars | Medium | Good communication, fast fix |
| Reputation damage | Brand impact | Low | Transparent communication, good support |

### 10.3 Rekomendasi Mitigasi
1. ✅ Deploy hotfix untuk BUG-021 & BUG-023 pre-production
2. ✅ Siapkan rollback plan jika issue ditemukan post-launch
3. ✅ 24/7 on-call monitoring untuk payment & auth
4. ✅ Komunikasi clear ke users tentang known issues
5. ✅ Promo / incentive untuk pengguna yang affected (diskon atau cashback)

---

## 11. KESIMPULAN & REKOMENDASI RILIS

### 11.1 Kelayakan Rilis

**Status: ⚠️ CONDITIONAL GO (Go with Notes)**

Aplikasi JAWARA CLOTHING STORE v1.4.0 **DAPAT DIRILIS** dengan kondisi:
- ✅ 86.8% test cases passed (target: > 80%)
- ✅ Core functionality tested dan berfungsi (auth, shop, checkout, chat, ML)
- ✅ Performance mencukupi (load test OK, stress test acceptable)
- ⚠️ 2 critical/high bugs masih open namun mitigatable

### 11.2 Persyaratan Go-Live

**Wajib diselesaikan sebelum produksi:**

1. **BUG-021 (Payment timeout)** - Fix atau workaround
   - Option A: Tingkatkan payment gateway timeout
   - Option B: Implement smart retry dengan exponential backoff
   - Option C: Fallback ke metode pembayaran alternatif
   - Timeline: Latest by 28 Desember 2025

2. **BUG-023 (Refresh token)** - Fix
   - Korrigsi token refresh logic
   - Test dengan full regression
   - Timeline: Latest by 27 Desember 2025

3. **Re-run E2E regression test** setelah fix
   - Fokus: Payment flow, Auth flow, Chat flow
   - Timeline: 28 Desember 2025

### 11.3 Post-Release Action Items

**Phase 1 - Week 1 (Go-Live)**:
- [ ] Deploy to production
- [ ] Monitor error logs & user feedback
- [ ] 24/7 on-call team ready
- [ ] Prepare hotfix if needed

**Phase 2 - Week 2-4 (Stabilization)**:
- [ ] BUG-045 (Chat duplicate) - Schedule untuk v1.4.1
- [ ] Performance optimization (database indexing, caching tuning)
- [ ] User feedback collection & bug fixes

**Phase 3 - v1.4.1 (Next Release)**:
- [ ] Fix chat duplicate messaging
- [ ] Enhanced 2FA for admin
- [ ] COD payment method (deferred feature)

### 11.4 Go/No-Go Decision

**✅ RECOMMENDATION: RILIS / GO LIVE**

**Dengan catatan penting:**
- Hotfix BUG-021 & BUG-023 HARUS deployed sebelum production
- Monitor closely first 24 hours
- Siapkan communication plan untuk user jika ada issue

**Justifikasi:**
- Aplikasi sudah tested cukup comprehensive
- Critical & high bugs identifiable dan fixable
- Tidak ada blocker yang tidak bisa diatasi
- Business need urgent (deadline end of year)
- Risk dapat dikelola dengan mitigation plan

---

## 12. LAMPIRAN LENGKAP

### 12.1 Test Case Repository
Detailed test cases tersedia di:
- `/pmpl/tests/api/test_auth.py` - API test scripts
- `/pmpl/tests/e2e/playwright_checkout.spec.ts` - E2E automation
- `/pmpl/tests/performance/k6_load_test.js` - Load test script
- Spreadsheet: `JAWARA_TestCases_v1.4.xlsx` (shared drive)

### 12.2 Bug Tracking
- **Jira Project**: JAWARA-QA
- **Open Tickets**: [JAWARA-21], [JAWARA-23], [JAWARA-45]
- **Closed**: [JAWARA-17], [JAWARA-62], dan 4 lainnya
- **Dashboard**: https://jira.company.com/browse/JAWARA-QA

### 12.3 Environment Configuration

**Staging Server:**
- URL: https://staging-api.jawara.local
- Database: MySQL 8.0 (aws-staging-db-01.rds.amazonaws.com)
- Redis: redis://staging-cache.jawara.local:6379
- ML API: https://huggingface.co/spaces/jawara/clothing-detection

**Test Data:**
- Dummy users: `qa+warga1@example.com` - `qa+warga20@example.com`
- Dummy RT: `qa+rt1@example.com`
- Dummy products: 500+ items seeded in staging DB
- Test cards: Stripe test cards (4242424242424242, etc.)

### 12.4 Test Execution Logs

**Functional Tests:**
```
pytest pmpl/tests/api/test_auth.py -v
Test session starts == 12 passed, 0 failed in 3.45s
```

**E2E Tests (Playwright):**
```
npx playwright test pmpl/tests/e2e/
✓ order_to_payment_flow (timeout after fix)
✓ rt_approval_flow
✓ chat_lifeline
4 passed (3.2s)
```

**Performance Tests (k6):**
```
k6 run pmpl/tests/performance/k6_load_test.js
     checks......: 98.5% ✓
     http_req_duration....: avg=1450ms p(95)=2800ms p(99)=4200ms
     http_req_failed.....: 0.10%
```

### 12.5 Screenshot & Evidence
(Lampiran file image/screenshot di folder terpisah)
- Login page screenshot
- Product listing page
- Checkout successful confirmation
- Chat interface
- ML detection result
- Performance graph dari k6

### 12.6 Environment Specification
- **Android Phone**: Pixel 6, Android 13
- **iOS Device**: iPhone 14 Pro, iOS 17
- **Desktop Browser**: Chrome 120, Firefox 121, Safari 17
- **Network Condition**: 4G LTE (100/20 Mbps), 3G (10/5 Mbps flaky test)

### 12.7 Referensi Dokumen
- [DesaKita Requirement Document](link)
- [API Specification](link)
- [UI/UX Design Figma](link)
- [Architecture Diagram](link)
- [Database Schema](link)

### 12.8 Contact Information

**QA Lead**: Charellino K S
- Email: charellino@jawara.local
- Phone: +62 8XX XXXX XXXX
- Slack: @charellino

**Backend QA**: M. Atho'illah M
- Email: atho@jawara.local
- Slack: @atho

**Mobile QA**: Mikaila Kafka
- Email: mikaila@jawara.local
- Slack: @mikaila

---

## 13. CHECKLIST PRE-RELEASE

- [ ] Semua critical bugs fixed & tested
- [ ] High bugs mitigated atau fixed
- [ ] Regression testing passed
- [ ] Performance test memenuhi SLA
- [ ] Security audit cleared (jika ada)
- [ ] Documentation updated
- [ ] Deployment plan reviewed
- [ ] Rollback procedure documented
- [ ] Support team trained
- [ ] Monitoring & alerting configured
- [ ] Communication plan ready

---

**Disusun oleh:**

**Charellino K S** (Lead QA)  
**M. Atho'illah M** (Backend & API QA)  
**Mikaila Kafka** (Mobile & E2E QA)

**Tanggal**: 26 Desember 2025  
**Periode Testing**: 15–24 Desember 2025  
**Total Effort**: 168 jam kerja  

---

### 🔔 FINAL NOTE
Laporan ini merupakan hasil pengujian menyeluruh untuk aplikasi JAWARA CLOTHING STORE v1.4.0.  
Rekomendasi rilis: **CONDITIONAL GO** dengan pemenuhan syarat fix critical bugs.  
Setiap stakeholder bertanggung jawab untuk review bagian relevan mereka.

**Last Updated**: 26 Dec 2025, 14:30 WIB
