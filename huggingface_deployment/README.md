---
title: Clothing Detection API - PCVK
emoji: 👕
colorFrom: blue
colorTo: green
sdk: gradio
sdk_version: 4.44.0
app_file: app.py
pinned: false
license: mit
---

# Clothing Detection API - PCVK

Model Machine Learning untuk deteksi kategori pakaian menggunakan **HOG (Histogram of Oriented Gradients) + SVM (Support Vector Machine)**.

## 🎯 Kategori yang Didukung

- 🧢 **Topi** (Hat)
- 👔 **Kemeja** (Shirt)  
- 👟 **Sepatu** (Shoes)
- 👕 **T-Shirt**

## 📊 Performance Metrics

- **Training Accuracy:** 100%
- **Validation Accuracy:** 86.47%
- **Test Accuracy:** 87.95%
- **Average Confidence:** 88.21%

### Per-Category Confidence (Test Set)

- Topi: 82.85%
- Kemeja: 84.19%
- Sepatu: 85.17%
- T-Shirt: 91.90%

## 🚀 Cara Menggunakan

### Via Web Interface

1. Upload gambar pakaian
2. Click "Detect Category"
3. Lihat hasil prediksi dengan confidence score

### Via API

```python
import requests
import json

# API endpoint (ganti dengan URL Space Anda)
url = "https://YOUR-SPACE-NAME.hf.space/api/predict"

# Upload image
with open("image.jpg", "rb") as f:
    files = {"data": f}
    response = requests.post(url, files=files)

# Parse hasil
result = response.json()
print(f"Predicted: {result['predicted_class']}")
print(f"Confidence: {result['confidence']:.2%}")
```

### Response Format

```json
{
    "success": true,
    "predicted_class": "Topi",
    "confidence": 0.7602,
    "top3_predictions": [
        {
            "class": "Topi",
            "confidence": 0.7602
        },
        {
            "class": "T-Shirt",
            "confidence": 0.1023
        },
        {
            "class": "Sepatu",
            "confidence": 0.0952
        }
    ],
    "method": "HOG + SVM"
}
```

## 🔧 Model Details

**Algorithm:** Support Vector Machine (SVM) with RBF kernel

**Feature Extraction:** HOG (Histogram of Oriented Gradients)
- Image size: 128x128
- Orientations: 9
- Pixels per cell: 8x8
- Cells per block: 2x2
- Block norm: L2-Hys

**Hyperparameters:**
- C: 10
- Gamma: scale
- Class weight: balanced
- Probability: True

**Training Data:**
- Original samples: 1,991
- With augmentation: 3,982
- Augmentation: horizontal flip, rotation, brightness, noise

**Model Size:** 145.98 MB

## 📝 Model Training

Model ditraining menggunakan GridSearchCV dengan:
- 32 kombinasi hyperparameter
- 3-fold cross validation
- Total: 96 model fits
- Training time: ~6-7 jam

## 🏗️ Deployment

Deployed on Hugging Face Spaces using Gradio.

## 📄 License

MIT License

## 👥 Authors

PBL Jawara Team
