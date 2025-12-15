---
title: PCVK Clothing Detection
emoji: 👕
colorFrom: blue
colorTo: green
sdk: gradio
sdk_version: 4.19.2
app_file: app.py
pinned: false
license: mit
---

# 👕 PCVK Clothing Detection API

Machine Learning API untuk deteksi kategori pakaian menggunakan HOG + SVM.

## 🎯 Categories

- **Topi** (Hat)  
- **Kemeja** (Shirt)  
- **Sepatu** (Shoes)  
- **Kaos** (T-Shirt)

## 🚀 Model Performance

- Training Accuracy: 100%
- Validation Accuracy: 86.47%
- Test Accuracy: 87.95%
- Method: HOG + RBF SVM
- Model Size: 145MB
- Inference Time: 1-3 seconds per image

## 📡 How to Use

### Via Web Interface

1. Click on the **App** tab above
2. Upload an image of clothing (T-shirt, Shirt, Shoes, or Hat)
3. Click **"🔍 Detect Category"**
4. View results with confidence scores

### Via API (Python)

```python
import requests

url = "https://huggingface.co/spaces/CrushedKatana/clothing-detection"
files = {"data": open("image.jpg", "rb")}

response = requests.post(url, files=files)
result = response.json()

print(result)
# Output: {
#   "success": true,
#   "predicted_class": "Topi",
#   "confidence": 0.95,
#   "top3_predictions": [...]
# }
```

### Via cURL

```bash
curl -X POST "https://huggingface.co/spaces/CrushedKatana/clothing-detection" \
  -F "data=@/path/to/image.jpg"
```

## 🔧 Technical Details

- **Framework**: Gradio 4.19.2
- **Image Processing**: OpenCV + scikit-image
- **Feature Extraction**: HOG (Histogram of Oriented Gradients)
  - Orientations: 9
  - Pixels per cell: 8x8
  - Cells per block: 2x2
  - Block norm: L2-Hys
- **Classifier**: SVM with RBF kernel
- **Preprocessing**: Histogram equalization for better feature extraction

## 📊 Dataset

- Training samples: 1393
- Validation samples: 199
- Total images: 1991
- Categories distribution:
  - T-Shirt: 50.8% (1011 images)
  - Sepatu: 21.6% (431 images)
  - Kemeja: 19.0% (378 images)
  - Topi: 8.6% (171 images)

## 🎓 Model Training

Model trained using:
- scikit-learn SVM with RBF kernel
- Grid search for hyperparameter optimization
- Cross-validation for robust performance
- Histogram equalization for feature normalization

Training code available in repository.

## 🐛 Known Issues

- May have lower accuracy for images with complex backgrounds
- Best results with clear, centered clothing images
- Recommended image size: 800x800px or smaller
- Maximum image size: 5MB

## 📝 License

MIT License - Free to use for commercial and personal projects.

## 👨‍💻 Author

**CrushedKatana**

## 🔗 Links

- [Dataset & Training Code](https://github.com/CrushedKatana/New_PBL_Jawara)
- [API Documentation](https://huggingface.co/spaces/CrushedKatana/clothing-detection)

---

**Last updated:** December 15, 2025
