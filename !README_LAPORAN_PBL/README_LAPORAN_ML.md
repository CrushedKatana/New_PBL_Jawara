# Laporan Proyek Pembelajaran Mesin

Judul: Klasifikasi Kategori Pakaian Berbasis HOG + SVM untuk Marketplace RT/RW

Program/Tim: PBL Jawara — PCVK Clothing Detection

Tanggal: 19 Desember 2025

---

## Selayang Pandang
Proyek ini mengotomatisasi pengkategorian produk pakaian pada marketplace RT/RW menggunakan pembelajaran mesin. Permasalahan yang dihadapi adalah proses kategorisasi manual yang lambat dan tidak konsisten. Solusi yang ditawarkan berupa model klasifikasi berbasis fitur Histogram of Oriented Gradients (HOG) dan Support Vector Machine (SVM), terintegrasi ke aplikasi mobile dan API cloud. Hasil menunjukkan akurasi pelatihan 98,71% dan akurasi validasi 77,69% pada empat kelas (Topi, Kemeja, Sepatu, T‑Shirt), sehingga layak untuk operasional dengan rencana peningkatan generalisasi.

---

## Dataset
Sumber data: Kaggle — Clothing Dataset (Full)
https://www.kaggle.com/datasets/agrigorev/clothing-dataset-full

Profil:
- 1.991 citra asli, empat kelas: Topi, Kemeja, Sepatu, T‑Shirt.
- Setelah augmentasi sederhana, total contoh pelatihan/validasi menjadi 3.982.
- Contoh visual dataset (lampiran): `images/ml_report/fig-01-dataset-samples.jpg`.

---

## Pra Pengolahan
- Konversi warna dan normalisasi kontras (equalize histogram) untuk kestabilan gradien.
- Resize ke resolusi seragam 128×128 piksel.
- Standarisasi fitur dengan `StandardScaler` setelah ekstraksi HOG.
- Augmentasi sederhana digunakan untuk meningkatkan keragaman (detail sesuai skrip pelatihan; contoh umum: flip/rotasi ringan/penyesuaian kontras).

---

## Ekstraksi Fitur
Metode utama: Histogram of Oriented Gradients (HOG)
- Orientations: 9
- Pixels per cell: 8×8
- Cells per block: 2×2
- Block normalization: L2‑Hys
- Dimensi fitur: ±8.100 per citra 128×128

---

## Pembuatan Data Latih
Strategi splitting yang digunakan: train/val/test = 70% / 10% / 20%.

Tabel pembagian data aktual:

| Rasio | Jml. Data Latih | Jml. Data Validasi | Jml. Data Uji |
|-------|------------------|--------------------|----------------|
| 70/10/20 (dipakai) | 2.786 | 399 | 797 |

Alternatif (rencana/modifikasi):

| Rasio / Metode | Jml. Data Latih | Jml. Data Uji |
|-----------------|------------------|----------------|
| 70:30 | — | — |
| 80:20 | — | — |
| 90:10 | — | — |
| kFold = 5 | — | — |

Catatan: Baris alternatif tidak dijalankan pada eksperimen ini dan dapat diadaptasi sesuai kebutuhan.

---

## Pembuatan Model
Model yang digunakan: Linear SVM (`LinearSVC`) dengan kalibrasi probabilitas (`CalibratedClassifierCV`).

Konfigurasi/hyperparameter:
- Kernel: Linear
- Regularisasi (C): 1.0
- Maksimal iterasi: 2.000
- Kalibrasi probabilitas: 3‑fold
- Optimisasi: Paralelisasi multi‑core CPU

Diagram pipeline (lampiran): `images/ml_report/fig-02-pipeline.png`.

---

## Evaluasi
Hasil evaluasi performa utama:

| Model | Akurasi (Train) | Akurasi (Val) | Presisi (Macro) | Recall (Macro) | F1‑Score (Macro) |
|-------|------------------|---------------|-----------------|----------------|------------------|
| HOG + Linear SVM | 98,71% | 77,69% | 96,94% | 95,12% | 95,98% |

Ringkasan uji (split 20% sebagai test):
- Confusion matrix (urutan kelas: Hat, Shirt, Shoes, T‑Shirt)
  [[30, 0, 2, 2],
   [1, 73, 0, 2],
   [0, 0, 84, 2],
   [0, 2, 1, 200]]
- Macro P/R/F1 = 0,969 / 0,951 / 0,960; Micro P/R/F1 (sama dengan akurasi) = 0,970.
- Artefak tersimpan: `ml_training/output/confusion_matrix.npy`, `ml_training/output/y_true.npy`, `ml_training/output/y_pred.npy`.

Contoh prediksi dan distribusi probabilitas (lampiran): `images/ml_report/fig-03-sample-prediction.png`.

---

## Kesimpulan
Pipeline HOG + SVM efektif untuk klasifikasi empat kelas pakaian pada skenario marketplace RT/RW, dengan kinerja validasi 77,69%. Model ringan, cepat, dan mudah dideploy. Peningkatan disarankan melalui perluasan dan keragaman dataset, augmentasi yang lebih kuat, serta penalaan regularisasi. Evaluasi tambahan (presisi/recall/F1) direkomendasikan untuk menilai performa per kelas.

---

## Kontribusi Anggota Tim

| Nama Anggota | Kontribusi |
|--------------|------------|
| … | … |
| … | … |
| … | … |

Silakan lengkapi nama dan kontribusi sesuai pembagian tugas tim.

---

## Referensi
1) A. Grigorev, Clothing Dataset (Full), Kaggle: https://www.kaggle.com/datasets/agrigorev/clothing-dataset-full
2) N. Dalal, B. Triggs, "Histograms of Oriented Gradients for Human Detection," CVPR 2005.
3) C. Cortes, V. Vapnik, "Support‑Vector Networks," Machine Learning, 1995.
4) F. Pedregosa et al., "Scikit‑learn: Machine Learning in Python," JMLR, 2011.

---

## Lampiran
- Cara reproduksi pelatihan: lihat `ml_training/train_model.py` dan `ml_training/output/TRAINING_RESULTS_LATEST.txt`.
- API Docker (HF Spaces): `huggingface_deployment/clothing-detection/`.
- Integrasi Flutter: `pbl_new/lib/core/services/clothing_detection_service.dart`.
- Konfigurasi endpoint: `pbl_new/lib/config/api_config.dart`.

Daftar gambar dan tabel:
- Gambar 1 — Contoh sampel dataset — `images/ml_report/fig-01-dataset-samples.jpg`
- Gambar 2 — Diagram pipeline — `images/ml_report/fig-02-pipeline.png`
- Gambar 3 — Contoh prediksi dan distribusi probabilitas — `images/ml_report/fig-03-sample-prediction.png`
