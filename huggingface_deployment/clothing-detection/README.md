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
