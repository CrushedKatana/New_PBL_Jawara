# ML Training - Deteksi Pakaian PCVK

## Overview
Modul Machine Learning untuk deteksi pakaian menggunakan teknologi Pengolahan Citra dan Visi Komputer (PCVK).

**Metode:**
- **HOG (Histogram of Oriented Gradients)** - Feature Extraction
- **SVM (Support Vector Machine)** - Classification

## Struktur Folder

```
ml_training/
├── dataset/              # Dataset untuk training
│   └── ml_ready_images_data.csv
├── models/              # Model terlatih
├── scripts/             # Script training dan preprocessing
│   ├── train_model.py
│   ├── preprocess.py
│   └── evaluate.py
└── output/              # Hasil training (logs, grafik, dll)
```

## Setup

### Requirements (Windows CMD)
```bat
REM Jika 'pip' tidak dikenali, gunakan Python launcher
py -3.14 -m pip install --upgrade pip
py -3.14 -m pip install -r ml_training\requirements.txt
```

### Alternatif: Anaconda/Miniconda (Direkomendasikan)

Jika Anda sudah menginstall Anaconda/Miniconda, gunakan environment terisolasi untuk stabilitas.

```cmd
:: Buka "Anaconda Prompt" (bukan CMD biasa), lalu jalankan:
conda create -n pcvk_ml python=3.11 -y
conda activate pcvk_ml

:: Masuk ke repo dan install dependencies
cd d:\CloneGithub\New_PBL_Jawara
pip install -r ml_training\requirements.txt

:: Jalankan training (di dalam env pcvk_ml)
python ml_training\scripts\train_model.py
```

Jika ingin memakai CMD biasa, pastikan conda sudah di-initialize:

```cmd
:: Jalankan dari "Anaconda Prompt":
conda init cmd.exe

:: Tutup dan buka kembali CMD, lalu aktifkan env:
conda activate pcvk_ml
```

### Dataset
Dataset terletak di `dataset/ml_ready_images_data.csv` yang berisi:
- Path gambar pakaian
- Label kategori pakaian
- Metadata gambar

## Training Model

### Method: HOG + SVM

**HOG (Histogram of Oriented Gradients):**
- Ekstraksi fitur gradien dari gambar
- Orientations: 9
- Pixels per cell: 8x8
- Cells per block: 2x2
- Transform sqrt: True

**SVM (Support Vector Machine):**
- Kernel: RBF (Radial Basis Function)
- Hyperparameter tuning dengan GridSearchCV (optional)
- Multi-class classification dengan One-vs-Rest

```bat
cd ml_training\scripts
REM Gunakan Python launcher di Windows
py train_model.py
```

**Training Process:**
1. Load dataset dari CSV
2. Preprocess gambar (grayscale, resize 128x128, histogram equalization)
3. Extract HOG features untuk setiap gambar
4. Feature normalization dengan StandardScaler
5. Train SVM classifier
6. Save model (.pkl) dan scaler (.pkl)

## Evaluasi Model

```bash
python evaluate.py --model ../models/clothing_detector.h5
```

## Integrasi dengan Aplikasi

### Warga Feature
- Upload foto pakaian
- Deteksi otomatis kategori pakaian
- Simpan hasil deteksi

### Admin Dashboard
- Statistik deteksi pakaian
- Akurasi model
- Jumlah deteksi per kategori
- Grafik performa ML
