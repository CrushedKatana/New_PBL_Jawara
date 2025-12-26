# LAPORAN PENGUJIAN PERANGKAT LUNAK (PMPL)

## 1. INFORMASI UMUM PROYEK
| Item | Keterangan |
| --- | --- |
| Nama Aplikasi/Perangkat Lunak | JAWARA CLOTHING  STORE|
| Versi Aplikasi | 1.4.0 (RC) |
| Periode Pengujian | 15–24 Desember 2025 |
| Tim Penguji | Charellino K S; M. Atho'illah M; Mikaila Kafka |
| Tanggal Penyelesaian Laporan | 26 Desember 2025 |

## 2. EXECUTIVE SUMMARY
- Tujuan: memverifikasi fungsi inti (auth, marketplace, chat, notifikasi, deteksi pakaian) serta kestabilan performa.
- Ruang lingkup: Functional, E2E, API, Unit & Integration, Performance.
- Ringkasan metrik: total 24 test case (fungsional+E2E+API); 21 Pass, 3 Fail, 0 Blocked ⇒ Success rate 87.5%.
- Temuan kritis: 1) Gateway pembayaran gagal timeout pada jalur E2E checkout; 2) Refresh token kadaluwarsa lebih cepat pada API `POST /auth/refresh`.
- Rekomendasi rilis: Go dengan catatan perbaiki bug pembayaran dan refresh token sebelum produksi.

## 3. LINGKUP DAN METODOLOGI PENGUJIAN
- Fitur diuji: login/registrasi, manajemen produk, keranjang & checkout, chat RT/warga, notifikasi, deteksi pakaian (HOG+SVM), profil & pengaturan.
- Fitur dikecualikan: pembayaran COD offline, dashboard analitik lanjutan admin (belum siap), push notif iOS (ditunda).
- Lingkungan: Windows 11, Android Emulator Pixel 6 (API 33), Chrome 120, Backend PHP + MySQL (staging), ML API HuggingFace Space.
- Tools: pytest+requests (API), Playwright (E2E web), Flutter integration test (mobile smoke), k6 (performance), coverage.py (unit), csv test data dummy.

## 4. HASIL PENGUJIAN FUNGSIONAL
### 4.1. PENGUJIAN FUNGSIONAL (FUNCTIONAL TESTING)
| Modul/Fitur | Test Case ID | Deskripsi | Hasil | Catatan/Bug ID |
| --- | --- | --- | --- | --- |
| Login | FUNC-LOG-001 | Login dengan kredensial valid | Pass | - |
| Login | FUNC-LOG-002 | Login dengan password salah | Pass | - |
| Produk | FUNC-PROD-003 | Tambah produk baru dengan semua field wajib | Pass | - |
| Produk | FUNC-PROD-004 | Upload foto produk > 2MB | Fail | BUG-017 (validasi ukuran) |
| Notifikasi | FUNC-NOT-005 | Toggle notifikasi dan simpan preferensi | Pass | - |
| Deteksi Pakaian | FUNC-ML-006 | Kirim foto dan terima label prediksi | Pass | - |
| Chat | FUNC-CHAT-007 | Kirim pesan teks RT ↔ warga | Pass | - |
| Pembayaran | FUNC-PAY-008 | Checkout dengan metode kartu | Pass | - |
| Pembayaran | FUNC-PAY-009 | Checkout dengan metode transfer | Pass | - |
| Profil | FUNC-PROF-010 | Ubah avatar dan simpan | Pass | - |
| Pengaturan | FUNC-SET-011 | Ganti bahasa ke EN | Pass | - |
| Pengaturan | FUNC-SET-012 | Ganti tema (gelap/terang) | Pass | - |

Ringkasan: Total 12, Pass 11, Fail 1, Success Rate 91.7%.

### 4.2. PENGUJIAN END-TO-END (E2E Testing)
| Scenario/Alur Bisnis | Test Case ID | Deskripsi Alur | Hasil | Catatan/Bug ID |
| --- | --- | --- | --- | --- |
| Order to Payment | E2E-ORD-001 | Login → pilih produk → checkout → bayar → konfirmasi | Fail | BUG-021 (gateway timeout) |
| RT Approval | E2E-RT-002 | Login RT → verifikasi warga baru → setujui | Pass | - |
| Notifikasi | E2E-NOT-003 | Trigger event transaksi → kirim push → tampil di app | Pass | - |
| Chat Lifeline | E2E-CHAT-004 | Login → buka chat → kirim & terima pesan | Pass | - |
| ML Detection Flow | E2E-ML-005 | Ambil foto → kirim ke API ML → tampilkan label & skor | Pass | - |

Ringkasan: Total 5, Pass 4, Fail 1, Success Rate 80%.

### 4.3. PENGUJIAN API (API Testing)
| API Endpoint | Method | Test Case ID | Test Scenario | Response Validation | Hasil | Catatan |
| --- | --- | --- | --- | --- | --- | --- |
| /api/v1/login | POST | API-LOG-001 | Kredensial valid | 200, token ada | Pass | - |
| /api/v1/login | POST | API-LOG-002 | Password salah | 401, pesan error | Pass | - |
| /api/v1/products | GET | API-PROD-003 | List produk publik | 200, schema OK | Pass | - |
| /api/v1/products | POST | API-PROD-004 | Tambah produk (auth) | 201, id dikembalikan | Pass | - |
| /api/v1/chat/{id}/send | POST | API-CHAT-005 | Kirim pesan warga ke RT | 200, message_id | Pass | - |
| /api/v1/ml/detect | POST | API-ML-006 | Upload foto pakaian | 200, label+score | Pass | - |
| /api/v1/auth/refresh | POST | API-AUTH-007 | Refresh token kedaluwarsa | 401 (ekspektasi 200) | Fail | BUG-023 |

Ringkasan: Total 7, Pass 6, Fail 1, Success Rate 85.7%.

### 4.4. PENGUJIAN UNIT & INTEGRASI (Unit & Integration Testing)
| Komponen/Unit | Integration Scope | Code Coverage | Hasil | Catatan |
| --- | --- | --- | --- | --- |
| AuthService | Integrasi dengan TokenProvider | 92% | Pass | Semua kasus auth lulus |
| ProductService | Integrasi dengan Cache & API | 88% | Pass | Cache hit 70% |
| NotificationService | Integrasi FCM | 81% | Pass | Perlu mock tambahan untuk iOS |
| MLDetectionService | Integrasi ke HF API | 85% | Pass | Latensi stabil < 1.2s |

Ringkasan: Total Unit Tests 120, Passed 118, Code Coverage rata-rata 87%, Integration Tests Passed 14 dari 15.

## 5. HASIL PENGUJIAN NON-FUNGSIONAL
### 5.1. PERFORMANCE TESTING
| Skenario Beban | Virtual Users | Avg Response Time (target) | Throughput (req/sec) | Error Rate | CPU/Memory Usage | Hasil vs Target |
| --- | --- | --- | --- | --- | --- | --- |
| Load (Normal) | 100 | 1.4s (<2s) | 160 | 0.1% | CPU 62% / Mem 58% | Memenuhi |
| Stress | 500 | 4.6s (<5s) | 410 | 0.7% | CPU 89% / Mem 82% | Warning (error rate) |
| Soak (2 jam) | 150 | 1.9s (<2.5s) | 170 | 0.2% | CPU 68% / Mem 65% | Memenuhi |

Analisis: Bottleneck pada gateway pembayaran saat stress (timeout). Optimasi: tambah retry eksponensial, tingkatkan pool DB checkout, aktifkan CDN untuk aset gambar produk.

## 6. TEMUAN BUG (DEFECT SUMMARY)
| Severity | Jumlah | Status (Open/Closed) | Rata-rata Waktu Perbaikan |
| --- | --- | --- | --- |
| Critical | 1 | Open:1 / Closed:0 | 6 jam |
| High | 2 | Open:1 / Closed:1 | 9 jam |
| Medium | 3 | Open:0 / Closed:3 | 12 jam |
| Low | 2 | Open:0 / Closed:2 | 18 jam |
| TOTAL | 8 | Open:2 / Closed:6 | - |

## 7. ANALISIS RISIKO
- Risiko rilis: pembayaran gagal (timeout) dapat memblok transaksi kartu; refresh token gagal menyebabkan logout mendadak.
- Dampak: kehilangan transaksi dan frustrasi user saat sesi habis.
- Workaround: fallback ke metode transfer/VA; force re-login saat refresh gagal dan tampilkan pesan jelas.

## 8. KESIMPULAN & REKOMENDASI
- Kelayakan: dapat dirilis setelah memperbaiki BUG-021 (payment timeout) dan BUG-023 (refresh token) serta re-run regression terbatas.
- Rekomendasi: RILIS DENGAN CATATAN perbaikan kritis; lakukan hotfix sebelum go-live.
- Tindak lanjut: re-test E2E checkout, API refresh token, dan stress test ulang gateway.

## 9. LAMPIRAN
- Detail test case & skrip: folder `tests/` di direktori ini.
- Defect log: rujuk catatan BUG-017, BUG-021, BUG-023 pada tracker internal.
- Cara ekspor ke PDF: gunakan print-to-PDF dari Markdown viewer atau `pandoc README.md -o LAPORAN_PMPL.pdf`.

---
Disusun oleh,

Charellino K S (Lead QA)
M. Atho'illah M
Mikaila Kafka
Melakukan pengujian perangkat lunak fungsional secara lengkap dan menyeluruh sebagai berikut:

Pengujian Fungsional
E2E Testing
API Testing
Unit Testing - Integration Testing
Pengujian Non Fungsional
Performance Testing
Pengujian perangkat lunak tersebut dilaporkan berbentuk pdf Laporan pengujian perangkat lunak dengan contoh format di bawah, kemudian disubmit dalam bucket submit di bawah.

LAPORAN PENGUJIAN PERANGKAT LUNAK

1. INFORMASI UMUM PROYEK

Item	Keterangan
Nama Aplikasi/Perangkat Lunak	
Versi Aplikasi	
Periode Pengujian	
Tim Penguji	
Tanggal Penyelesaian Laporan	

2. EXECUTIVE SUMMARY

Ringkasan tujuan dan ruang lingkup pengujian.

Metrik ringkasan hasil (total test case, passed, failed, blocked, success rate).

Temuan kritis/isu utama yang ditemukan.

Rekomendasi kelayakan rilis (Go/No-Go) dengan justifikasi.



3. LINGKUP DAN METODOLOGI PENGUJIAN

Fitur/fungsi yang diuji dan yang dikecualikan.

Lingkungan pengujian (OS, Browser, Device, Server, dll).

Tools yang digunakan untuk setiap jenis pengujian.



4. HASIL PENGUJIAN FUNGSIONAL

4.1. PENGUJIAN FUNGSIONAL (FUNCTIONAL TESTING)

Modul/Fitur	Test Case ID	Deskripsi	Hasil (Pass/Fail/Block)	Catatan/Bug ID
Contoh: Login	FUNC-LOG-001	Login dengan kredensial valid	Pass	-
...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%


4.2. PENGUJIAN END-TO-END (E2E Testing)

Scenario/Alur Bisnis	Test Case ID	Deskripsi Alur	Hasil	Catatan/Bug ID
Contoh: Order to Payment	E2E-ORD-001	Login - Pilih produk - Checkout - Bayar - Konfirmasi	Pass	-
...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%

4.3. PENGUJIAN API (API Testing)

API Endpoint	Method	Test Case ID	Test Scenario (Params, Body)	Response Validation	Hasil	Catatan
Contoh: /api/v1/login	POST	API-LOG-001	Valid credentials	HTTP 200, token returned	Pass	-
...	...	...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%		


4.4. PENGUJIAN UNIT & INTEGRASI (Unit & Integration Testing)
Catatan: Hasil ini biasanya dari tim developer.

Komponen/Unit	Integration Scope	Code Coverage	Hasil	Catatan
Contoh: UserService	Integrasi dengan AuthModule	95%	Pass	Semua unit test passed
...	...	...	...	...
RINGKASAN	Total Unit Tests: X	Passed: Y	Code Coverage Avg: Z%	Integration Tests Passed: A dari B


5. HASIL PENGUJIAN NON-FUNGSIONAL

5.1. PERFORMANCE TESTING

Tujuan: Mengevaluasi respons waktu, throughput, dan stabilitas di bawah beban tertentu.

Tools: (contoh: JMeter, LoadRunner, k6)

Skenario & Metrik:

Skenario Beban	Virtual Users	Avg Response Time (Target)	Throughput (req/sec)	Error Rate	CPU/Memory Usage	Hasil vs Target
Load Test (Normal)	100	< 2 detik	150	0%	65%	Memenuhi
Stress Test	500	< 5 detik	400	0.5%	90%	Warning di error rate
...	...	...	...	...	...	...


Analisis & Rekomendasi:

Bottleneck yang teridentifikasi (misalnya: database query lambat).

Saran optimasi.

6. TEMUAN BUG (DEFECT SUMMARY)

Severity	Jumlah	Status (Open/Closed)	Rata-rata Waktu Perbaikan
Critical			
High			
Medium			
Low			
TOTAL			


7. ANALISIS RISIKO

Risiko yang masih ada setelah pengujian.

Dampak terhadap user jika dirilis dalam kondisi saat ini.

Workaround yang mungkin.



8. KESIMPULAN & REKOMENDASI

Apakah aplikasi memenuhi kriteria kelayakan rilis?

Rekomendasi: DIRILIS / TUNDA / PERLU PERBAIKAN KRITIS TERLEBIH DAHULU

Tindak lanjut yang diperlukan sebelum rilis.



9. LAMPIRAN

Link test plan/case detail.

Link defect report.

Log pengujian, screenshot, atau dokumen pendukung.

Environment configuration detail.

Disusun oleh,

[Nama Lead QA/Tester]
[Tanda Tangan]

Melakukan pengujian perangkat lunak fungsional secara lengkap dan menyeluruh sebagai berikut:

Pengujian Fungsional
E2E Testing
API Testing
Unit Testing - Integration Testing
Pengujian Non Fungsional
Performance Testing
Pengujian perangkat lunak tersebut dilaporkan berbentuk pdf Laporan pengujian perangkat lunak dengan contoh format di bawah, kemudian disubmit dalam bucket submit di bawah.

LAPORAN PENGUJIAN PERANGKAT LUNAK

1. INFORMASI UMUM PROYEK

Item	Keterangan
Nama Aplikasi/Perangkat Lunak	
Versi Aplikasi	
Periode Pengujian	
Tim Penguji	
Tanggal Penyelesaian Laporan	

2. EXECUTIVE SUMMARY

Ringkasan tujuan dan ruang lingkup pengujian.

Metrik ringkasan hasil (total test case, passed, failed, blocked, success rate).

Temuan kritis/isu utama yang ditemukan.

Rekomendasi kelayakan rilis (Go/No-Go) dengan justifikasi.



3. LINGKUP DAN METODOLOGI PENGUJIAN

Fitur/fungsi yang diuji dan yang dikecualikan.

Lingkungan pengujian (OS, Browser, Device, Server, dll).

Tools yang digunakan untuk setiap jenis pengujian.



4. HASIL PENGUJIAN FUNGSIONAL

4.1. PENGUJIAN FUNGSIONAL (FUNCTIONAL TESTING)

Modul/Fitur	Test Case ID	Deskripsi	Hasil (Pass/Fail/Block)	Catatan/Bug ID
Contoh: Login	FUNC-LOG-001	Login dengan kredensial valid	Pass	-
...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%


4.2. PENGUJIAN END-TO-END (E2E Testing)

Scenario/Alur Bisnis	Test Case ID	Deskripsi Alur	Hasil	Catatan/Bug ID
Contoh: Order to Payment	E2E-ORD-001	Login - Pilih produk - Checkout - Bayar - Konfirmasi	Pass	-
...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%

4.3. PENGUJIAN API (API Testing)

API Endpoint	Method	Test Case ID	Test Scenario (Params, Body)	Response Validation	Hasil	Catatan
Contoh: /api/v1/login	POST	API-LOG-001	Valid credentials	HTTP 200, token returned	Pass	-
...	...	...	...	...	...	...
RINGKASAN	Total: X	Pass: Y	Fail: Z	Success Rate: Y/X*100%		


4.4. PENGUJIAN UNIT & INTEGRASI (Unit & Integration Testing)
Catatan: Hasil ini biasanya dari tim developer.

Komponen/Unit	Integration Scope	Code Coverage	Hasil	Catatan
Contoh: UserService	Integrasi dengan AuthModule	95%	Pass	Semua unit test passed
...	...	...	...	...
RINGKASAN	Total Unit Tests: X	Passed: Y	Code Coverage Avg: Z%	Integration Tests Passed: A dari B


5. HASIL PENGUJIAN NON-FUNGSIONAL

5.1. PERFORMANCE TESTING

Tujuan: Mengevaluasi respons waktu, throughput, dan stabilitas di bawah beban tertentu.

Tools: (contoh: JMeter, LoadRunner, k6)

Skenario & Metrik:

Skenario Beban	Virtual Users	Avg Response Time (Target)	Throughput (req/sec)	Error Rate	CPU/Memory Usage	Hasil vs Target
Load Test (Normal)	100	< 2 detik	150	0%	65%	Memenuhi
Stress Test	500	< 5 detik	400	0.5%	90%	Warning di error rate
...	...	...	...	...	...	...


Analisis & Rekomendasi:

Bottleneck yang teridentifikasi (misalnya: database query lambat).

Saran optimasi.

6. TEMUAN BUG (DEFECT SUMMARY)

Severity	Jumlah	Status (Open/Closed)	Rata-rata Waktu Perbaikan
Critical			
High			
Medium			
Low			
TOTAL			


7. ANALISIS RISIKO

Risiko yang masih ada setelah pengujian.

Dampak terhadap user jika dirilis dalam kondisi saat ini.

Workaround yang mungkin.



8. KESIMPULAN & REKOMENDASI

Apakah aplikasi memenuhi kriteria kelayakan rilis?

Rekomendasi: DIRILIS / TUNDA / PERLU PERBAIKAN KRITIS TERLEBIH DAHULU

Tindak lanjut yang diperlukan sebelum rilis.



9. LAMPIRAN

Link test plan/case detail.

Link defect report.

Log pengujian, screenshot, atau dokumen pendukung.

Environment configuration detail.

Disusun oleh,

[Nama Lead QA/Tester]
[Tanda Tangan]

