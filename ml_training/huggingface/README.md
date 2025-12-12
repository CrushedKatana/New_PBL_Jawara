---
title: Clothing Detection API
emoji: 👕
colorFrom: blue
colorTo: purple
sdk: docker
pinned: false
license: mit
---

# Clothing Detection API 👕

API untuk deteksi kategori pakaian menggunakan Machine Learning (HOG + SVM).

## Kategori yang Dideteksi

- 👒 **Topi** (Hat)
- 👔 **Kemeja** (Shirt)  
- 👟 **Sepatu** (Shoes)
- 👕 **T-Shirt**

## Teknologi

- **Model**: Support Vector Machine (SVM) dengan RBF kernel
- **Feature Extraction**: Histogram of Oriented Gradients (HOG)
- **Framework**: FastAPI
- **Deployment**: Hugging Face Spaces

## API Endpoints

### 1. Health Check
```
GET /
```

Response:
```json
{
  "status": "online",
  "message": "Clothing Detection API is running",
  "version": "1.0.0",
  "categories": ["Topi", "Kemeja", "Sepatu", "T-Shirt"]
}
```

### 2. Predict Category
```
POST /predict
```

Request:
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body: `file` (image file - JPG/PNG)

Response:
```json
{
  "success": true,
  "predicted_class": "Topi",
  "confidence": 0.9979730467136989,
  "top3_predictions": [
    {
      "class": "Topi",
      "confidence": 0.9979730467136989
    },
    {
      "class": "T-Shirt",
      "confidence": 0.0015234567
    },
    {
      "class": "Sepatu",
      "confidence": 0.0005034966
    }
  ],
  "method": "HOG + SVM"
}
```

### 3. Health Status
```
GET /health
```

Response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "categories": ["Topi", "Kemeja", "Sepatu", "T-Shirt"]
}
```

## Usage Example

### cURL
```bash
curl -X POST "https://your-space.hf.space/predict" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@image.jpg"
```

### Python
```python
import requests

url = "https://your-space.hf.space/predict"
files = {"file": open("image.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

### Flutter/Dart
```dart
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> detectClothing(String imagePath) async {
  var request = http.MultipartRequest(
    'POST', 
    Uri.parse('https://your-space.hf.space/predict')
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('file', imagePath)
  );
  
  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  
  return json.decode(response.body);
}
```

## Model Performance

- **Training Accuracy**: 100.00%
- **Validation Accuracy**: 86.47%
- **Test Accuracy**: 87.95%
- **Average Confidence**: 88.21%

### Per-Category Confidence (Test Set)
- Topi: 82.85%
- Kemeja: 84.19%
- Sepatu: 85.17%
- T-Shirt: 91.90%

## Model Details

- **Algorithm**: Support Vector Machine (SVM)
- **Kernel**: RBF (Radial Basis Function)
- **Parameters**: 
  - C=10
  - gamma='scale'
  - class_weight='balanced'
- **Feature Extraction**: HOG (Histogram of Oriented Gradients)
  - Image size: 128x128
  - Orientations: 9
  - Pixels per cell: (8, 8)
  - Cells per block: (2, 2)
- **Training Data**: 3,982 images (with augmentation)
- **Model Size**: ~146 MB

## Deployment

This API is deployed on Hugging Face Spaces using Docker SDK for optimal performance.

## License

MIT License
