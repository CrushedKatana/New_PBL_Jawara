# 🚀 Cara Deploy ke Hugging Face Spaces

## Langkah 1: Persiapan File

Pastikan folder `huggingface_deployment` kamu punya file-file ini:

```
huggingface_deployment/
├── app.py                          ✅ Main application file
├── requirements.txt                ✅ Dependencies
├── clothing_svm_best.pkl          ✅ Model file
├── clothing_scaler_best.pkl       ✅ Scaler file
├── label_mapping.json             ✅ Category mapping
└── README.md                      ✅ Space description
```

**PENTING:** File `app.py` HARUS ada di root folder!

## Langkah 2: Clone Space dari Hugging Face

### A. Install Git LFS (Large File Storage) - Untuk file model >10MB

**Windows:**
```bash
# Download dari: https://git-lfs.github.com/
# Atau via Chocolatey:
choco install git-lfs

# Initialize
git lfs install
```

**Mac:**
```bash
brew install git-lfs
git lfs install
```

**Linux:**
```bash
sudo apt install git-lfs
git lfs install
```

### B. Clone Space

```bash
# Clone space kosong (ganti username kamu)
git clone https://huggingface.co/spaces/CrushedKatana/clothing-detection
cd clothing-detection
```

Jika muncul error "repository not found", buat Space dulu di website.

## Langkah 3: Buat Space di Hugging Face (Jika Belum Ada)

1. Login ke https://huggingface.co
2. Klik **"New"** → **"Space"**
3. Isi form:
   - **Owner:** CrushedKatana (atau username kamu)
   - **Space name:** `clothing-detection`
   - **License:** MIT
   - **Select the Space SDK:** **Gradio**
   - **Space hardware:** CPU basic (gratis)
   - **Visibility:** Public
4. Klik **"Create Space"**

## Langkah 4: Copy File ke Space

```bash
# Masuk ke folder space yang sudah di-clone
cd clothing-detection

# Copy semua file dari huggingface_deployment
# Windows (PowerShell):
Copy-Item -Path "D:\CloneGithub\New_PBL_Jawara\huggingface_deployment\*" -Destination . -Recurse

# Windows (CMD):
xcopy /E /I "D:\CloneGithub\New_PBL_Jawara\huggingface_deployment\*" .

# Linux/Mac:
cp -r ../huggingface_deployment/* .
```

## Langkah 5: Track Model Files dengan Git LFS

Model files > 10MB harus di-track dengan Git LFS:

```bash
# Track .pkl files
git lfs track "*.pkl"

# Verify
cat .gitattributes
# Harusnya muncul: *.pkl filter=lfs diff=lfs merge=lfs -text
```

## Langkah 6: Commit & Push

```bash
# Add all files
git add .

# Check status
git status

# Commit
git commit -m "Initial deployment: HOG+SVM clothing detection model"

# Push to Hugging Face
git push
```

**Username:** CrushedKatana (atau username HF kamu)  
**Password:** Pakai **Access Token**, BUKAN password akun!

### Cara Buat Access Token:

1. Klik profile → **Settings**
2. Klik **"Access Tokens"**
3. Klik **"New token"**
4. Name: `space-deploy`
5. Role: **Write**
6. Klik **"Generate a token"**
7. Copy token (hanya tampil sekali!)
8. Paste sebagai password saat git push

## Langkah 7: Tunggu Build

1. Buka https://huggingface.co/spaces/CrushedKatana/clothing-detection
2. Space akan otomatis build (2-5 menit)
3. Status:
   - 🟡 **Building** → Sedang install dependencies
   - 🟢 **Running** → Berhasil! Space sudah live
   - 🔴 **Error** → Ada masalah, cek Logs

## Langkah 8: Test Space

1. Klik tab **"App"**
2. Upload foto pakaian
3. Klik **"Detect Category"**
4. Lihat hasil

## Troubleshooting

### Error: "No application file"

**Penyebab:** File `app.py` tidak ada di root folder

**Fix:**
```bash
# Pastikan app.py ada
ls -la app.py

# Jika tidak ada, copy lagi
cp ../huggingface_deployment/app.py .

# Commit & push
git add app.py
git commit -m "Add app.py"
git push
```

### Error: "ModuleNotFoundError"

**Penyebab:** Package tidak ada di requirements.txt

**Fix:** Edit `requirements.txt`, tambahkan package yang kurang:
```txt
gradio==4.19.2
numpy==1.26.4
opencv-python-headless==4.8.1.78
scikit-image==0.22.0
scikit-learn==1.3.2
joblib==1.3.2
Pillow==10.1.0
```

Commit & push:
```bash
git add requirements.txt
git commit -m "Fix requirements"
git push
```

### Error: "File size too large"

**Penyebab:** Model file >10MB tapi tidak di-track Git LFS

**Fix:**
```bash
# Remove from regular git
git rm --cached clothing_svm_best.pkl clothing_scaler_best.pkl

# Track with LFS
git lfs track "*.pkl"

# Re-add
git add .gitattributes *.pkl

# Commit & push
git commit -m "Track model files with LFS"
git push
```

### Error: "Runtime Error" saat build

**Cek logs:**
1. Klik tab **"Logs"**
2. Lihat error message terakhir (warna merah)
3. Fix sesuai error

**Error umum:**
- Missing model files → Copy file .pkl
- Wrong file path → Pastikan path relatif (bukan absolute)
- Memory error → Resize image atau upgrade hardware

## Update Space (Setelah Deploy Pertama)

```bash
# Edit file (misalnya app.py)
nano app.py

# Commit & push
git add .
git commit -m "Update: improve detection accuracy"
git push

# Space akan auto-rebuild dalam 2-3 menit
```

## Structure Check (Harus Sama Persis!)

```bash
# Di folder clothing-detection (hasil clone)
tree -L 1

clothing-detection/
├── .git/
├── .gitattributes           # Git LFS config
├── app.py                   # ✅ WAJIB ADA di root!
├── requirements.txt         # ✅ WAJIB ADA
├── clothing_svm_best.pkl    # Model (tracked by LFS)
├── clothing_scaler_best.pkl # Scaler (tracked by LFS)
├── label_mapping.json       # Optional but recommended
└── README.md                # Space description
```

## Quick Commands Summary

```bash
# 1. Clone
git clone https://huggingface.co/spaces/CrushedKatana/clothing-detection
cd clothing-detection

# 2. Copy files
cp -r ../huggingface_deployment/* .

# 3. Git LFS
git lfs install
git lfs track "*.pkl"

# 4. Push
git add .
git commit -m "Deploy clothing detection model"
git push

# 5. Check space
# Open: https://huggingface.co/spaces/CrushedKatana/clothing-detection
```

## Video Tutorial (Steps)

1. **Buat Space** (1 min) → New Space → Gradio → Create
2. **Clone** (30 sec) → `git clone https://...`
3. **Copy files** (1 min) → Copy app.py, model, requirements.txt
4. **Git LFS** (1 min) → Track .pkl files
5. **Push** (2 min) → Commit + push
6. **Wait build** (3-5 min) → Space auto-build
7. **Test** (1 min) → Upload image → Detect

**Total waktu:** ~10 menit

## Tips

✅ **Gunakan Git LFS** untuk file >10MB  
✅ **Check .gitattributes** pastikan *.pkl tracked  
✅ **Test lokal dulu** sebelum deploy: `python app.py`  
✅ **Monitor logs** saat build untuk debug  
✅ **Upgrade hardware** jika perlu (CPU → GPU)  

## Kontak

Jika stuck:
1. Screenshot error + logs
2. Tanya di HF Community Forum
3. Atau buat issue GitHub

Good luck! 🚀
