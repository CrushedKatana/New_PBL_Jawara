# PCVK CLOTHING DETECTION REPORT

## 1. Overview

The PCVK (Pengolahan Citra dan Visi Komputer) component of **JAWARA CLOTHING STORE** implements an end‑to‑end clothing detection feature that automatically classifies clothing photos into four categories:

- Hat (Topi)
- Shirt (Kemeja)
- T‑Shirt (Kaos)
- Shoes (Sepatu)

This report focuses on:
- Languages and technologies used
- The HOG + SVM method and data pipeline
- Libraries and tools
- Integration between Python ML, PHP backend, and Flutter mobile client
- Key code snippets and example screenshots.

---

## 2. Languages & Technology Stack

### 2.1 Machine Learning Layer (Training & Inference)

- **Language**: Python 3.x
- **Main Files** (see `ml_training/`):
  - `ml_training/scripts/preprocess.py`
  - `ml_training/scripts/train_model.py`
  - `ml_training/scripts/predict.py`
  - `ml_training/models/clothing_svm_best.pkl`
  - `ml_training/models/clothing_scaler_best.pkl`
- **Core Libraries**:
  - `numpy` – numeric arrays
  - `scikit-image` – HOG feature extraction
  - `scikit-learn` – SVM classifier, train/test split, metrics
  - `joblib` – model persistence (save/load `.pkl` files)
  - `pillow` or `opencv-python` – image loading & resizing (depending on env)

### 2.2 Backend Integration Layer

- **Language**: PHP 8.x
- **Location**: `pbl_new/backend/ml_detection.php`
- **Responsibility**:
  - Receive image upload from Flutter
  - Call Python `predict.py` via CLI
  - Parse JSON result from Python and return a clean JSON API response
  - Optionally log detections into MySQL table `ml_detections` using `05_ml_detections.sql`.

### 2.3 Mobile Client Layer (Flutter)

- **Language**: Dart (Flutter)
- **Key Files**:
  - `pbl_new/lib/core/services/clothing_detection_service.dart`
  - `pbl_new/lib/features/warga/screens/camera_detection_screen.dart`
  - `pbl_new/lib/features/warga/screens/add_product_screen.dart`
- **Core Packages**:
  - `http` – call backend ML API
  - `image_picker` / `camera` – capture or pick photos
  - Flutter state management (Provider/BLoC) – bind detection result to UI

---

## 3. Method: HOG + SVM

### 3.1 HOG (Histogram of Oriented Gradients)

- Input image is resized to **128×128** pixels.
- Image is converted to grayscale and normalized.
- HOG parameters (see `ml_training/scripts/preprocess.py` and PCVK guide):
  - `orientations = 9` (gradient directions)
  - `pixels_per_cell = (8, 8)`
  - `cells_per_block = (2, 2)`
  - `transform_sqrt = True`
- Output: one HOG feature vector per image with **8,100 dimensions**.

### 3.2 SVM Classifier

- Algorithm: **Support Vector Machine (SVM)** with RBF kernel.
- Parameters (see `ml_training/scripts/train_model.py`):
  - `kernel='rbf'`
  - `C=10.0`
  - `gamma='scale'`
  - `decision_function_shape='ovr'` (One‑vs‑Rest for multi‑class)
  - `probability=True` (to get confidence scores)
- Dataset:
  - Source: Kaggle Clothing Dataset
  - 4 classes: Hat, Shirt, T‑Shirt, Shoes
  - 1,991 original images → 3,982 augmented samples
  - Split: 60% train, 20% validation, 20% test
- Performance (baseline PCVK model):
  - Accuracy ≈ 88%
  - Inference time ≈ 50–100 ms per image on CPU

---

## 4. Architecture & Data Flow

### 4.1 High‑Level Flow

```text
Flutter App (Warga)
  └─ "Jual Pakaian" → "Tambah Produk" → [PCVK Button]
        ↓
Take photo / pick image (camera_detection_screen.dart)
        ↓
Send image file via HTTP multipart to PHP backend
        ↓
PHP (ml_detection.php) calls Python predict.py
        ↓
Python loads HOG+SVM model, extracts features, predicts class
        ↓
Python outputs JSON → PHP forwards JSON to Flutter
        ↓
Flutter displays predicted category + confidence,
auto‑fills product category field, and can save history.
```

### 4.2 Key Components

- **Python**: pure ML logic (feature extraction + classification)
- **PHP**: glue layer between HTTP and Python; also writes logs to `ml_detections` table.
- **Flutter**: user‑facing UI that triggers detection, shows results, and stores history.

---

## 5. Example Code Snippets

### 5.1 Python – HOG Feature Extraction & SVM Prediction

**File**: `ml_training/scripts/predict.py` (simplified example)

```python
from skimage.feature import hog
from skimage.io import imread
from skimage.transform import resize
import joblib
import json
import sys

# Load model & scaler
model = joblib.load('../models/clothing_svm_best.pkl')
scaler = joblib.load('../models/clothing_scaler_best.pkl')

IMAGE_SIZE = (128, 128)

def extract_hog_features(image_path):
    img = imread(image_path, as_gray=True)
    img_resized = resize(img, IMAGE_SIZE)
    features = hog(
        img_resized,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        transform_sqrt=True,
    )
    return features

if __name__ == "__main__":
    image_path = sys.argv[1]
    feats = extract_hog_features(image_path).reshape(1, -1)
    feats_scaled = scaler.transform(feats)

    probs = model.predict_proba(feats_scaled)[0]
    classes = model.classes_
    top_idx = probs.argmax()

    result = {
        "success": True,
        "predicted_class": str(classes[top_idx]),
        "confidence": float(probs[top_idx]),
    }

    print(json.dumps(result))
```

This script is invoked by PHP and prints a **single JSON line**, which is then returned to the mobile app.

### 5.2 PHP – Backend Endpoint

**File**: `pbl_new/backend/ml_detection.php`

```php
function detectClothing($imagePath) {
    $pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
    $modelPath   = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
    $scalerPath  = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';
    $pythonExe   = 'C:\\Users\\chare\\AppData\\Local\\Python\\bin\\python.exe';

    $command = sprintf(
        '"%s" "%s" --image "%s" --model "%s" --scaler "%s" 2>&1',
        $pythonExe,
        $pythonScript,
        $imagePath,
        $modelPath,
        $scalerPath
    );

    exec($command, $output, $returnCode);
    $outputStr = implode("\n", $output);

    if ($returnCode !== 0) {
        return [
            'success' => false,
            'message' => 'Python execution failed',
            'debug'   => $outputStr,
        ];
    }

    $result = json_decode($outputStr, true);
    return $result ?: [
        'success' => false,
        'message' => 'Invalid JSON from ML script',
        'raw_output' => $outputStr,
    ];
}
```

The actual file adds more robust error handling and database logging (see `pbl_new/backend/ml_detection.php`).

### 5.3 Dart/Flutter – ML API Client

**File**: `pbl_new/lib/core/services/clothing_detection_service.dart`

```dart
class ClothingDetectionService {
  static String get _detectEndpoint => ApiConfig.mlDetectionEndpoint;

  static Future<Map<String, dynamic>> detectClothing(
    String imagePath,
    int userId, {
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Map<String, dynamic>? lastError;

    while (attempt <= maxRetries) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }

        final request = http.MultipartRequest('POST', Uri.parse(_detectEndpoint));
        request.files.add(
          await http.MultipartFile.fromPath('data', imagePath),
        );

        final streamed = await request.send().timeout(
          const Duration(seconds: 90),
        );
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final fullResult = json.decode(response.body);

          // Direct ML result format
          if (fullResult is Map && fullResult.containsKey('predicted_class')) {
            fullResult['user_id'] = userId;
            return Map<String, dynamic>.from(fullResult);
          }

          return {
            'success': false,
            'message': 'Unexpected response format',
            'raw_response': fullResult,
          };
        }

        return {
          'success': false,
          'message': 'API Error ${response.statusCode}',
        };
      } catch (e) {
        lastError = {
          'success': false,
          'message': 'Exception while calling ML API',
          'detail': e.toString(),
        };
        attempt++;
      }
    }

    return lastError ?? {
      'success': false,
      'message': 'Failed to contact ML server',
    };
  }
}
```

## 6. Screenshots (Suggested)

You can include the following screenshots in the final PDF (capture from the running app and backend console):

1. **Mobile – Add Product with PCVK Button**  
   `![Add Product with PCVK Button](../assets/screenshots/pcvk_add_product_button.png)`

2. **Mobile – Camera Detection Screen**  
   `![Camera Detection Screen](../assets/screenshots/pcvk_camera_detection.png)`

3. **Mobile – Detection Result Shown in Form**  
   `![Detection Result Autofill](../assets/screenshots/pcvk_detection_result.png)`

4. **Backend – ml_detections Table in phpMyAdmin**  
   `![ML Detections Table](../assets/screenshots/pcvk_ml_detections_table.png)`

5. **Admin Dashboard – PCVK Statistics**  
   `![PCVK Admin Dashboard](../assets/screenshots/pcvk_admin_dashboard.png)`


---

## 7. Summary

- PCVK uses a **Python HOG + SVM** model for clothing classification, trained on ~4K images and saved as `.pkl` files.
- A **PHP** backend endpoint wraps the Python script and exposes a clean JSON REST API.
- The **Flutter** mobile app integrates PCVK through `ClothingDetectionService`, sending images and displaying predictions in the "Jual Pakaian" flow.
- The feature is designed to be **fast, interpretable, and deployable** on common CPU‑only infrastructure.

This report can be used as the **PCVK main chapter** in your final document/slide/PDF for explaining the implementation details end‑to‑end.
