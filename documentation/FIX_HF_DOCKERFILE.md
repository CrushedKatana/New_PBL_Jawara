# Cara Fix Dockerfile di Hugging Face Space

## Error yang Terjadi
```
E: Package 'libgl1-mesa-glx' has no installation candidate
```

## Penyebab
Package `libgl1-mesa-glx` sudah tidak tersedia di Debian Trixie (base image Python 3.10-slim)

## Solusi: Edit Dockerfile di Web

### Langkah-langkah:

1. **Buka Dockerfile di HF Space**
   ```
   https://huggingface.co/spaces/CrushedKatana/clothing_clasification/blob/main/Dockerfile
   ```

2. **Klik tombol "Edit" (icon pensil) di kanan atas**

3. **Ganti line 5** dari:
   ```dockerfile
   libgl1-mesa-glx \
   ```
   
   Menjadi:
   ```dockerfile
   libgl1 \
   ```

4. **Hasil akhir line 4-7 harus seperti ini:**
   ```dockerfile
   RUN apt-get update && apt-get install -y \
       libgl1 \
       libglib2.0-0 \
       && rm -rf /var/lib/apt/lists/*
   ```

5. **Scroll ke bawah, klik "Commit changes to main"**

6. **Build akan otomatis trigger** (5-10 menit)
   - Monitor di: https://huggingface.co/spaces/CrushedKatana/clothing_clasification?logs=build

7. **Setelah build success**, endpoint akan aktif:
   ```
   https://crushedkatana-clothing-clasification.hf.space/detect
   ```

## Verifikasi Fix Berhasil

### Test endpoint dengan curl:
```bash
curl https://crushedkatana-clothing-clasification.hf.space/health
```

Expected response:
```json
{"status": "healthy", "model_loaded": true}
```

### Test detection dengan image:
```bash
curl -X POST https://crushedkatana-clothing-clasification.hf.space/detect \
  -F "image=@path/to/shirt.jpg"
```

Expected response:
```json
{
  "category": "Kemeja",
  "confidence": 0.92,
  "all_predictions": {
    "Kemeja": 0.92,
    "Kaos": 0.05,
    "Topi": 0.02,
    "Sepatu": 0.01
  }
}
```

## Alternative: Setup Git Authentication

Jika ingin push dari terminal (butuh HF token):

1. **Generate token** di: https://huggingface.co/settings/tokens
   - Buat token dengan scope: `write`

2. **Setup git credential:**
   ```bash
   cd pbl_new/clothing_clasification
   git remote set-url origin https://<USERNAME>:<TOKEN>@huggingface.co/spaces/CrushedKatana/clothing_clasification
   ```

3. **Push changes:**
   ```bash
   git push origin main
   ```

## File yang Sudah Benar (Lokal)

File Dockerfile di lokal sudah benar:
```
d:\CloneGithub\New_PBL_Jawara\pbl_new\clothing_clasification\Dockerfile
```

Hanya perlu sync ke HF Space dengan cara di atas.
