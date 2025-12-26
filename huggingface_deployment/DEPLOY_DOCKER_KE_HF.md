# 🐳 Deploy Docker ke Hugging Face Spaces

## Kenapa Pakai Docker?

✅ **Full Control** - Pakai Flask/FastAPI/apa saja  
✅ **Production Ready** - Lebih stabil dari Gradio  
✅ **Custom Dependencies** - Install library apapun  
✅ **Sudah Ready** - File Docker sudah ada di folder kamu!  

## Langkah Deploy

### 1. Buat Space dengan SDK Docker

1. Login https://huggingface.co
2. Klik **"New"** → **"Space"**
3. Isi form:
   - Space name: `clothing-detection`
   - SDK: **Docker** ← PENTING!
   - Hardware: CPU basic
   - Visibility: Public
4. Klik **"Create Space"**

### 2. Clone Space

```bash
git clone https://huggingface.co/spaces/CrushedKatana/clothing-detection
cd clothing-detection
```

### 3. Copy File Docker

```bash
# Copy file dari clothing-detection folder
# Windows CMD:
cd clothing-detection
xcopy /E /I "D:\CloneGithub\New_PBL_Jawara\huggingface_deployment\clothing-detection\*" .

# Atau manual copy file ini:
# - Dockerfile
# - ml_api_docker.py
# - requirements_docker.txt
# - clothing_svm_best.pkl
# - clothing_scaler_best.pkl
```

### 4. Buat README.md untuk Space

Buat file `README.md` dengan front matter:

```markdown
---
title: Clothing Detection API
emoji: 👕
colorFrom: blue
colorTo: green
sdk: docker
app_port: 5000
---

# Clothing Detection API

Flask API untuk deteksi kategori pakaian.

## Endpoints

- `POST /detect` - Upload image
- `GET /health` - Health check
```

### 5. Track Model dengan Git LFS

```bash
git lfs install
git lfs track "*.pkl"
```

### 6. Commit & Push

```bash
git add .
git commit -m "Deploy Docker: Flask API for clothing detection"
git push
```

**Password:** Gunakan Access Token (bukan password!)

### 7. Tunggu Build (5-10 menit)

Docker build lebih lama dari Gradio karena install dependencies.

Status:
- 🟡 **Building** → Installing packages
- 🟢 **Running** → API sudah live!
- 🔴 **Error** → Cek Logs

## Test API

### Via cURL

```bash
curl -X POST "https://crushedkatana-clothing-detection.hf.space/detect" \
  -F "data=@C:/path/to/image.jpg"
```

### Via Python

```python
import requests

url = "https://crushedkatana-clothing-detection.hf.space/detect"
files = {"data": open("image.jpg", "rb")}

response = requests.post(url, files=files)
result = response.json()
print(result)
```

### Health Check

```bash
curl https://crushedkatana-clothing-detection.hf.space/health
```

## Struktur File (Docker)

```
clothing-detection/
├── .git/
├── .gitattributes
├── Dockerfile                    ✅ WAJIB!
├── README.md                     ✅ Front matter dengan sdk: docker
├── ml_api_docker.py              ✅ Flask app
├── requirements_docker.txt       ✅ Dependencies
├── clothing_svm_best.pkl         ✅ Model (Git LFS)
└── clothing_scaler_best.pkl      ✅ Scaler (Git LFS)
```

## Perbedaan Gradio vs Docker

| Feature | Gradio | Docker |
|---------|--------|--------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐ Medium |
| **UI** | ✅ Auto-generated | ❌ Build sendiri |
| **API** | ✅ Ada | ✅ Full control |
| **Customization** | ⭐⭐ Limited | ⭐⭐⭐⭐⭐ Full |
| **Production** | ⭐⭐⭐ OK | ⭐⭐⭐⭐⭐ Best |
| **Build Time** | ~2-3 min | ~5-10 min |
| **Dependencies** | Must fit Gradio | Any! |

## Troubleshooting

### Error: "Port must match app_port"

Pastikan `README.md` front matter:
```yaml
sdk: docker
app_port: 5000  ← Harus match port di Dockerfile EXPOSE
```

### Error: Docker build failed

Cek logs, biasanya:
- Missing dependencies → Edit `requirements_docker.txt`
- Wrong COPY path → Pastikan file ada
- Out of memory → Resize model atau upgrade hardware

### Error: Health check failed

Edit Dockerfile, disable health check:
```dockerfile
# Comment out health check sementara
# HEALTHCHECK --interval=30s ...
```

## Update Space

```bash
# Edit file
nano ml_api_docker.py

# Commit & push
git add .
git commit -m "Update: improve API"
git push

# Space auto-rebuild
```

## Rekomendasi

**Pakai Gradio jika:**
- Butuh demo cepat
- Perlu UI visual
- Untuk showcase/portfolio

**Pakai Docker jika:**
- Production app
- Custom API structure
- Integrasi dengan Flutter app
- Butuh control penuh

## File Yang Sudah Ready

Kamu sudah punya semua file Docker:
- ✅ `clothing-detection/Dockerfile`
- ✅ `clothing-detection/ml_api_docker.py`
- ✅ `clothing-detection/requirements_docker.txt`

Tinggal copy ke Space dan push! 🚀
