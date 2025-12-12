---
title: Clothing Detection HOG SVM
emoji: 👔
colorFrom: blue
colorTo: green
sdk: gradio
sdk_version: 4.44.1
app_file: huggingface_app.py
pinned: false
license: mit
models:
  - custom
tags:
  - computer-vision
  - image-classification
  - clothing
  - hog
  - svm
  - indonesia
---

# Clothing Detection - HOG + SVM

Sistem deteksi kategori pakaian menggunakan **Histogram of Oriented Gradients (HOG)** untuk ekstraksi fitur dan **Support Vector Machine (SVM)** dengan RBF kernel untuk klasifikasi.

## Kategori yang Didukung

- 🧢 **Topi** (Hat)
- 👔 **Kemeja** (Shirt)  
- 👟 **Sepatu** (Shoes)
- 👕 **T-Shirt**

## Model Performance

- **Training Accuracy:** 100.00%
- **Validation Accuracy:** 86.47%
- **Test Accuracy:** 87.95%
- **Average Confidence:** 88.21%

### Per-Category Confidence (Test Set)
- Topi: 82.85%
- Kemeja: 84.19%
- Sepatu: 85.17%
- T-Shirt: 91.90%

## Technical Details

- **Algorithm:** Support Vector Machine (SVM) with RBF kernel
- **Feature Extraction:** HOG (Histogram of Oriented Gradients)
- **Best Parameters:** 
  - C=10
  - gamma='scale'
  - class_weight='balanced'
- **Training Method:** GridSearchCV with 3-fold cross-validation
- **Data Augmentation:** 2x (horizontal flip, rotation, brightness, noise)
- **Training Samples:** 3,982 (1,991 original + augmentation)
- **Model Size:** 146 MB

## Usage

### Web Interface
Simply upload an image of clothing item and click "Deteksi Kategori" to get predictions.

### API Endpoint

```python
import requests

# Upload image
files = {"image": open("path/to/image.jpg", "rb")}
response = requests.post(
    "https://YOUR_SPACE_URL/api/predict",
    files=files
)
result = response.json()

print(f"Predicted: {result['predicted_class']}")
print(f"Confidence: {result['confidence']}")
```

### Flutter/Dart Integration

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> detectClothing(String imagePath) async {
  var request = http.MultipartRequest(
    'POST', 
    Uri.parse('https://YOUR_SPACE_URL/api/predict')
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('image', imagePath)
  );
  
  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  
  return json.decode(response.body);
}
```

## Training Details

The model was trained using:
- **Dataset:** Custom clothing dataset
- **Optimization:** GridSearchCV with 32 parameter combinations
- **Cross-Validation:** 3-fold CV (96 total model fits)
- **Training Time:** ~6-7 hours
- **Feature Descriptor:** 
  - Orientations: 9
  - Pixels per cell: (8, 8)
  - Cells per block: (2, 2)
  - Block norm: L2-Hys

## Project

This model is part of the **Marketplace RT/RW PBL Project** - a community marketplace application with AI-powered clothing categorization.

## License

MIT License
