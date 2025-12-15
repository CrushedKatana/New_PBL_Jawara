---
title: PCVK Clothing Detection API
emoji: 👕
colorFrom: blue
colorTo: green
sdk: docker
app_port: 5000
pinned: false
license: mit
---

# 👕 PCVK Clothing Detection API

Machine Learning API untuk deteksi kategori pakaian menggunakan HOG + SVM.

## 🎯 Categories

- **Topi** (Hat)  
- **Kemeja** (Shirt)  
- **Sepatu** (Shoes)  
- **T-Shirt**

## 🚀 Model Performance

- Training Accuracy: 100%
- Validation Accuracy: 86.47%
- Test Accuracy: 87.95%
- Method: HOG + RBF SVM

## 📡 API Endpoints

This repo provides two deployment options:

1) Hugging Face Space (existing): forwards requests to the Space endpoint.
2) FastAPI Proxy (Docker): a lightweight FastAPI that proxies to Hugging Face or a local endpoint.

### POST /detect
Detect clothing category from image.

**Request:**
```bash
curl -X POST -F "data=@image.jpg" https://crushedkatana-clothing-detection.hf.space/detect
```

**Response:**
```json
{
  "data": ["{\"success\": true, \"predicted_class\": \"Topi\", \"confidence\": 0.998}"]
}
```

### GET /health
Health check endpoint.

## 🔧 Technical Details

- Framework: Flask + Gunicorn
- Image Processing: OpenCV + scikit-image
- Feature Extraction: HOG (Histogram of Oriented Gradients)
- Model: RBF SVC
- Inference Time: 1-3 seconds per image

## 🐳 FastAPI Proxy (Docker)

Build and run a small FastAPI service that proxies `/detect` to Hugging Face Space:

```bash
docker build -f Dockerfile.fastapi -t clothing-detection-fastapi .
docker run --rm -p 8000:8000 clothing-detection-fastapi
```

Test:

```bash
curl -X POST "http://localhost:8000/detect" -F "image=@/path/to/your.jpg"
```

Override upstream endpoint:

```bash
docker run --rm -e HF_ENDPOINT="http://192.168.1.2:5000/detect" -p 8000:8000 clothing-detection-fastapi
```
